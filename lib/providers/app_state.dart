import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/mock_data.dart';
import '../models/admin_models.dart';
import '../models/models.dart';
import '../services/nyiha_api.dart';

enum AppScreen {
  splash,
  onboarding,
  register,
  terms,
  payment,
  login,
  resetPassword,
  main,
  pendingApproval,
  adminLogin,
  adminMain,
}

class AppState extends ChangeNotifier {
  static const _kMemberJwt = 'nyiha_member_jwt';
  static const _kAdminJwt = 'nyiha_admin_jwt';
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  /// After failed API call (register / login).
  String? lastApiError;

  /// Member JWT from API (`null` = guest / demo until login).
  String? memberJwt;

  /// Admin JWT when using API auth.
  String? adminJwt;

  AppScreen screen = AppScreen.splash;
  int onboardStep = 0;
  int regStep = 1;
  final Map<String, String> regData = {};
  int mainTabIndex = 0;

  /// Community sub: 0 chat community, 1 admin, 2 members, 3 events, 4 mkeka, 5 polls
  int communitySection = 0;

  // —— Admin console (max 3: 1 main + 2 helpers) ——
  AdminAccount? adminSession;
  final List<AdminAccount> adminTeam = [
    AdminAccount(
      id: 'adm-main',
      displayName: 'Adam Administrator',
      email: 'adamadministrator@nyiha.app',
      role: AdminRole.main,
      pin: '0000',
      linkedMemberPhone: '+255712345678',
    ),
  ];

  /// When `false`, only kituo accounts with [AdminAccount.linkedMemberPhone] matching the logged-in user may post in Mazungumzo ya Jamii.
  bool jamiiCommunityChatMembersCanSend = true;

  final List<ManagedMember> managedMembers = [];

  /// New registrations awaiting admin (after ada + form).
  final List<PendingSignupRequest> pendingSignupRequests = [];

  /// Shown on "waiting for approval" screen — editable in admin Settings.
  String customerCarePhone = '+255 700 000 111';
  String customerCareWhatsApp = '+255 700 000 222';
  String customerCareHoursLabel = 'Jumatatu–Ijumaa · 08:00–18:00';

  /// User app: which bottom tabs exist (admins can hide entire areas).
  bool showUserTabHome = true;
  bool showUserTabJamii = true;
  bool showUserTabDuka = true;
  bool showUserTabProfile = true;

  /// Jamii sub-sections (chips inside Jamii tab).
  bool showJamiiMazungumzo = true;
  bool showJamiiAdminChat = true;
  bool showJamiiWanachama = true;
  bool showJamiiMatukio = true;
  bool showJamiiMkeka = true;
  bool showJamiiKura = true;

  int adminShellIndex = 0;

  /// When true (standalone `admins` runner), hide "back to member app" on admin login.
  bool isAdminStandaloneOnly = false;

  /// Duka catalog — admins add/remove; user Duka tab reads this list.
  late List<MockProduct> dukaProducts;
  /// Matangazo ya wakuu — admins publish; home / Matangazo hub read this list.
  late List<AdminCommunityPost> matangazoPosts;
  /// Matukio ya kalenda (sehemu ya Matangazo kwenye programu ya mtumiaji) — editable katika Settings → Admin Posts.
  /// Initialized at declaration so hot reload never leaves this unset (unlike `late` + constructor-only init).
  List<MockEvent> jamiiEvents = List<MockEvent>.from(mockEvents);

  bool isDark = true;
  bool termsAccepted = false;

  NyihaUser user = NyihaUser(
    name: 'Lulez Mtemi',
    phone: '+255712345678',
    email: '',
    location: 'Dar es Salaam',
    children: 2,
    status: 'Approved',
    ticksPaid: 12,
    balance: 2000,
    username: 'lulez_nyiha',
    avatarUrl: null,
  );

  /// Target tiki / bei (updated from `/settings` and `/me`).
  int ticksRequiredAnnualSetting = 24;
  int tickPriceTzsSetting = 2000;

  PendingTickPayment? pendingTickPayment;

  String chatTarget = 'community';
  final List<ChatMsg> messagesCommunity = [];
  final List<ChatMsg> messagesAdmin = [];
  /// Buyer ↔ duka seller (from cart / oda flow).
  final List<ChatMsg> messagesSeller = [];

  final Random _rng = Random();
  Timer? _autoRefreshTimer;
  DateTime? _lastCatalogRefreshAt;
  DateTime? _lastMembersRefreshAt;
  DateTime? _lastChatsRefreshAt;
  bool _refreshInFlight = false;

  late List<MockPoll> polls;

  AppState() {
    dukaProducts = List<MockProduct>.from(mockProducts);
    matangazoPosts = List<AdminCommunityPost>.from(mockAdminCommunityPosts);
    _initManagedMembers();
    _initMessages();
    _initAdminPostReactions();
    polls = [
      MockPoll(
        q: 'Tungependa mkutano ufanyike wapi?',
        options: [
          PollOption(t: 'Mbeya', v: 34),
          PollOption(t: 'Dar es Salaam', v: 28),
          PollOption(t: 'Songwe', v: 18),
        ],
      ),
      MockPoll(
        q: 'Mkeka uongezwe hadi ngapi kwa mwezi?',
        options: [
          PollOption(t: 'TZS 2,000', v: 45),
          PollOption(t: 'TZS 3,000', v: 22),
          PollOption(t: 'TZS 5,000', v: 8),
        ],
      ),
    ];
  }

  void _initManagedMembers() {
    managedMembers.clear();
    const phones = [
      '+255712111001',
      '+255712111002',
      '+255712111003',
      '+255712111004',
      '+255712111005',
      '+255712111006',
      '+255712345678',
      '+255712111008',
    ];
    var i = 0;
    for (final m in mockMembers) {
      managedMembers.add(
        ManagedMember(
          name: m.name,
          phone: i < phones.length ? phones[i] : '+25570000000${i}',
          location: m.loc,
          ticks: m.ticks,
          emoji: m.emoji,
          status: m.name == 'Lulez Mtemi' ? MemberStatus.approved : MemberStatus.approved,
        ),
      );
      i++;
    }
  }

  bool get isAdminLoggedIn => adminSession != null;
  bool get isMainAdminSession => adminSession?.role == AdminRole.main;

  static const int maxAdminAccounts = 3;

  bool get canAddHelperAdmin =>
      isMainAdminSession && adminTeam.where((a) => a.role == AdminRole.helper).length < 2;

  int get helperCount => adminTeam.where((a) => a.role == AdminRole.helper).length;

  /// Logged-in seat label, e.g. `Main Admin`, `Admin 02`, `Admin 03`.
  String get adminSessionSeatLabel {
    final s = adminSession;
    if (s == null) return 'Admin';
    return adminSeatLabelFor(s);
  }

  /// Seat label for a team account (main vs numbered helpers).
  String adminSeatLabelFor(AdminAccount a) {
    if (a.role == AdminRole.main) return 'Main Admin';
    final helpers = adminTeam.where((x) => x.role == AdminRole.helper).toList()
      ..sort((x, y) => x.id.compareTo(y.id));
    final idx = helpers.indexWhere((x) => x.id == a.id);
    if (idx < 0) return 'Msaidizi';
    return 'Admin ${(idx + 2).toString().padLeft(2, '0')}';
  }

  /// Semantic indices 0–3: Home, Jamii, Duka, Profile.
  List<int> get enabledUserTabIndices {
    final r = <int>[];
    if (showUserTabHome) r.add(0);
    if (showUserTabJamii) r.add(1);
    if (showUserTabDuka) r.add(2);
    if (showUserTabProfile) r.add(3);
    return r.isEmpty ? [0, 1, 2, 3] : r;
  }

  void ensureUserMainTabValid() {
    if (enabledUserTabIndices.contains(mainTabIndex)) return;
    mainTabIndex = enabledUserTabIndices.first;
    notifyListeners();
  }

  /// Which Jamii chips (semantic 0–5) stay visible.
  List<int> get enabledJamiiSectionIndices {
    final r = <int>[];
    if (showJamiiMazungumzo) r.add(0);
    if (showJamiiAdminChat) r.add(1);
    if (showJamiiWanachama) r.add(2);
    if (showJamiiMatukio) r.add(3);
    if (showJamiiMkeka) r.add(4);
    if (showJamiiKura) r.add(5);
    return r.isEmpty ? [0, 1, 2, 3, 4, 5] : r;
  }

  void ensureCommunitySectionValid() {
    if (enabledJamiiSectionIndices.contains(communitySection)) return;
    communitySection = enabledJamiiSectionIndices.first;
    if (communitySection <= 1) {
      chatTarget = communitySection == 0 ? 'community' : 'admin';
    }
    notifyListeners();
  }

  void setUserTabVisibility({bool? home, bool? jamii, bool? duka, bool? profile}) {
    if (home != null) showUserTabHome = home;
    if (jamii != null) showUserTabJamii = jamii;
    if (duka != null) showUserTabDuka = duka;
    if (profile != null) showUserTabProfile = profile;
    ensureUserMainTabValid();
    notifyListeners();
  }

  void setJamiiSectionVisibility({
    bool? mazungumzo,
    bool? adminChat,
    bool? wanachama,
    bool? matukio,
    bool? mkeka,
    bool? kura,
  }) {
    if (mazungumzo != null) showJamiiMazungumzo = mazungumzo;
    if (adminChat != null) showJamiiAdminChat = adminChat;
    if (wanachama != null) showJamiiWanachama = wanachama;
    if (matukio != null) showJamiiMatukio = matukio;
    if (mkeka != null) showJamiiMkeka = mkeka;
    if (kura != null) showJamiiKura = kura;
    ensureCommunitySectionValid();
    notifyListeners();
  }

  bool loginAdmin({required String email, required String pin}) {
    final e = email.trim().toLowerCase();
    final p = pin.trim();
    for (final a in adminTeam) {
      if (a.email.toLowerCase() == e && a.pin == p) {
        adminSession = a;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> logoutAdmin() async {
    adminSession = null;
    adminShellIndex = 0;
    await saveAdminJwt(null);
    _stopAutoRefresh();
  }

  /// Main admin only: add a helper until 3 admins total.
  bool addHelperAdmin({
    required String displayName,
    required String email,
    required String pin,
  }) {
    if (!canAddHelperAdmin) return false;
    if (adminTeam.length >= maxAdminAccounts) return false;
    final dn = displayName.trim();
    final em = email.trim().toLowerCase();
    final p = pin.trim();
    if (dn.isEmpty || em.isEmpty || p.isEmpty) return false;
    if (adminTeam.any((a) => a.email.toLowerCase() == em)) return false;
    final id = 'adm-h${DateTime.now().millisecondsSinceEpoch}';
    adminTeam.add(
      AdminAccount(
        id: id,
        displayName: dn,
        email: em,
        role: AdminRole.helper,
        pin: p,
        linkedMemberPhone: null,
      ),
    );
    notifyListeners();
    return true;
  }

  bool removeHelperAdmin(String id) {
    if (!isMainAdminSession) return false;
    final idx = adminTeam.indexWhere((a) => a.id == id);
    if (idx < 0) return false;
    if (adminTeam[idx].role == AdminRole.main) return false;
    adminTeam.removeAt(idx);
    notifyListeners();
    return true;
  }

  void setAdminShellIndex(int i) {
    adminShellIndex = i.clamp(0, 4);
    notifyListeners();
  }

  static String _normalizePhoneDigits(String? s) {
    if (s == null) return '';
    return s.replaceAll(RegExp(r'\D'), '');
  }

  /// Whether the current member-app user may send messages in community Jamii chat (text/image/voice).
  bool get canCurrentUserPostCommunityChat {
    if (jamiiCommunityChatMembersCanSend) return true;
    final up = _normalizePhoneDigits(user.phone);
    if (up.isEmpty) return false;
    for (final a in adminTeam) {
      final lp = a.linkedMemberPhone;
      if (lp != null && _normalizePhoneDigits(lp) == up) return true;
    }
    return false;
  }

  /// Member (when allowed) or logged-in admin — drives [CommunityChatComposer] `canPost`.
  bool get canSendJamiiComposer =>
      (adminJwt != null && adminJwt!.isNotEmpty && adminSession != null) ||
      canCurrentUserPostCommunityChat;

  /// Same gate for uploads (image/voice).
  bool get canPostCommunityMedia => canSendJamiiComposer;

  void setJamiiCommunityChatMembersCanSend(bool value) {
    jamiiCommunityChatMembersCanSend = value;
    notifyListeners();
  }

  void setMemberStatus(String name, MemberStatus status) {
    for (final m in managedMembers) {
      if (m.name == name) {
        m.status = status;
        notifyListeners();
        return;
      }
    }
  }

  MemberStatus _memberStatusFromApi(String? s) {
    switch (s?.toLowerCase()) {
      case 'approved':
        return MemberStatus.approved;
      case 'pending':
        return MemberStatus.pending;
      case 'suspended':
        return MemberStatus.suspended;
      default:
        return MemberStatus.pending;
    }
  }

  /// Update member ticks, status, admin notes / warning; persists to API and [managedMembers].
  Future<bool> patchManagedMemberApi(
    ManagedMember member, {
    MemberStatus? status,
    int? ticks,
    int? balanceTzs,
    String? adminProfileNote,
    String? adminWarning,
  }) async {
    final tok = adminJwt;
    final id = member.id;
    if (tok == null || tok.isEmpty || id == null || id.isEmpty) return false;
    final body = <String, dynamic>{};
    if (status != null) {
      body['status'] = switch (status) {
        MemberStatus.approved => 'approved',
        MemberStatus.pending => 'pending',
        MemberStatus.suspended => 'suspended',
      };
    }
    if (ticks != null) body['ticksPaid'] = ticks;
    if (balanceTzs != null) body['balance'] = balanceTzs;
    if (adminProfileNote != null) body['adminProfileNote'] = adminProfileNote;
    if (adminWarning != null) body['adminWarning'] = adminWarning;
    if (body.isEmpty) return false;
    try {
      final j = await NyihaApi.patch('/admin/members/$id', body, bearer: tok);
      if (j['status'] != null) {
        member.status = _memberStatusFromApi(j['status']?.toString());
      }
      final tp = j['ticksPaid'] ?? j['ticks'];
      if (tp is num) member.ticks = tp.toInt();
      final bal = j['balance'];
      if (bal is num) member.balanceTzs = bal.toInt();
      member.adminProfileNote = j['adminProfileNote']?.toString() ?? member.adminProfileNote;
      member.adminWarning = j['adminWarning']?.toString() ?? member.adminWarning;
      notifyListeners();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> setManagedMemberStatusApi(ManagedMember member, MemberStatus status) {
    return patchManagedMemberApi(member, status: status);
  }

  void broadcastAdminNotice(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    messagesAdmin.insert(
      0,
      ChatMsg(
        from: adminSession?.displayName ?? 'Admin',
        text: trimmed,
        time: time,
        me: false,
        emoji: '⚡',
      ),
    );
    notifyListeners();
  }

  Future<bool> adminSendCommunityMessageApi(String text) async {
    final tok = adminJwt;
    if (tok == null || tok.isEmpty) return false;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    try {
      await NyihaApi.post('/admin/chat/community', {
        'text': trimmed,
        'timeLabel': time,
        'emoji': '🛡️',
        'mediaKind': 'text',
      }, bearer: tok);
      await fetchCommunityChatsApi();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  void adminRejectPendingTickPayment() {
    final p = pendingTickPayment;
    if (p == null || p.phase != TickPaymentPhase.waitingAdminApproval) return;
    final n = p.tickCount;
    pendingTickPayment = null;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    messagesAdmin.insert(
      0,
      ChatMsg(
        from: 'Admin',
        text:
            'Ombi la malipo la tiki $n limekataliwa na ${adminSession?.displayName ?? "wasimamizi"}. Mteja anaweza kutuma ombi jipya.',
        time: time,
        me: false,
        emoji: '⛔',
      ),
    );
    notifyListeners();
  }

  void adminSetOrderStatus(int index, String status) {
    if (index < 0 || index >= shopOrders.length) return;
    shopOrders[index].status = status;
    notifyListeners();
  }

  void addDukaProduct({
    required String name,
    required String priceLabel,
    required String emoji,
    required String imageUrl,
    int color = 0xFFD4A017,
  }) {
    final n = name.trim();
    if (n.isEmpty) return;
    dukaProducts.add(
      MockProduct(
        name: n,
        priceLabel: priceLabel.trim(),
        emoji: emoji.trim().isEmpty ? '🛍️' : emoji.trim(),
        color: color,
        imageUrl: imageUrl.trim().isEmpty ? kDefaultAdminCommunityPostImage : imageUrl.trim(),
      ),
    );
    notifyListeners();
  }

  void removeDukaProductAt(int index) {
    if (index < 0 || index >= dukaProducts.length) return;
    dukaProducts.removeAt(index);
    notifyListeners();
  }

  void updateDukaProductAt(
    int index, {
    required String name,
    required String priceLabel,
    required String emoji,
    required String imageUrl,
    int color = 0xFFD4A017,
  }) {
    if (index < 0 || index >= dukaProducts.length) return;
    final n = name.trim();
    if (n.isEmpty) return;
    dukaProducts[index] = MockProduct(
      name: n,
      priceLabel: priceLabel.trim(),
      emoji: emoji.trim().isEmpty ? '🛍️' : emoji.trim(),
      color: color,
      imageUrl: imageUrl.trim().isEmpty ? kDefaultAdminCommunityPostImage : imageUrl.trim(),
    );
    notifyListeners();
  }

  /// Admin/seller reply in the shared buyer ↔ duka chat ([messagesSeller]).
  void adminSendSellerReply(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final label = adminSession?.displayName ?? 'Muuzaji Duka';
    messagesSeller.add(
      ChatMsg(
        from: label,
        text: trimmed,
        time: time,
        me: false,
        emoji: '🛍️',
      ),
    );
    notifyListeners();
  }

  void addMatangazoPost({
    required String headline,
    required String body,
    required String tag,
    String? imageUrl,
  }) {
    final h = headline.trim();
    if (h.isEmpty) return;
    final now = DateTime.now();
    final id = 'post-${now.millisecondsSinceEpoch}';
    final urls = (imageUrl != null && imageUrl.trim().isNotEmpty)
        ? [imageUrl.trim()]
        : [kDefaultAdminCommunityPostImage];
    matangazoPosts.insert(
      0,
      AdminCommunityPost(
        id: id,
        authorLabel: adminSession?.displayName ?? 'Wakuu wa Jamii',
        headline: h,
        body: body.trim(),
        dateLabel: '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
        tag: tag.trim().isEmpty ? 'Habari' : tag.trim(),
        imageUrls: urls,
      ),
    );
    _ensureAdminPostReactions(id);
    notifyListeners();
  }

  void removeMatangazoAt(int index) {
    if (index < 0 || index >= matangazoPosts.length) return;
    final id = matangazoPosts[index].id;
    matangazoPosts.removeAt(index);
    _adminPostReactionCounts.remove(id);
    _myAdminPostReaction.remove(id);
    notifyListeners();
  }

  void addJamiiEvent({
    required String title,
    required String desc,
    required String date,
    required String tag,
  }) {
    final t = title.trim();
    if (t.isEmpty) return;
    jamiiEvents.insert(
      0,
      MockEvent(
        title: t,
        desc: desc.trim(),
        date: date.trim(),
        tag: tag.trim().isEmpty ? 'Matukio' : tag.trim(),
      ),
    );
    notifyListeners();
  }

  void removeJamiiEventAt(int index) {
    if (index < 0 || index >= jamiiEvents.length) return;
    jamiiEvents.removeAt(index);
    notifyListeners();
  }

  int get pendingMemberCount => managedMembers.where((m) => m.status == MemberStatus.pending).length;

  int get pendingApprovalQueueCount {
    var n = pendingMemberCount;
    if (pendingTickPayment?.phase == TickPaymentPhase.waitingAdminApproval) n++;
    n += shopOrders.where((o) => o.status.toLowerCase().contains('inasubiri')).length;
    return n;
  }

  void _initMessages() {
    messagesCommunity
      ..clear()
      ..addAll([
        ChatMsg(from: 'Agnes Mwakasege', text: 'Habari za asubuhi wote! Mkutano wa wiki ijayo utafanyika Dar.', time: '09:14', me: false, emoji: '👩🏿'),
        ChatMsg(from: 'Petro Mwakasege', text: 'Asante Agnes. Nitakuwepo. Niwasiliane na wengine.', time: '09:22', me: false, emoji: '👨🏿'),
        ChatMsg(from: 'You', text: 'Mimi pia nitashiriki. Mungu awabariki wote!', time: '10:05', me: true),
        ChatMsg(from: 'Mama Zuhura', text: 'Bora sana. Tuhakikishe michango yote inalipwa kabla ya mkutano.', time: '10:18', me: false, emoji: '👩🏾'),
      ]);
    messagesAdmin
      ..clear()
      ..addAll([
        ChatMsg(from: 'Admin', text: 'Karibu Nyiha App! Akaunti yako imeidhinishwa. Hongera!', time: 'Jana', me: false, emoji: '⚡'),
        ChatMsg(from: 'Admin', text: 'Kumbuka kulipa Mkeka wako wa mwezi huu kabla ya tarehe 28.', time: 'Jana', me: false, emoji: '⚡'),
      ]);
    messagesSeller.clear();
  }

  /// Per-post reaction totals (fire, like, love, cry, hungry).
  final Map<String, Map<String, int>> _adminPostReactionCounts = {};
  final Map<String, String?> _myAdminPostReaction = {};

  void _initAdminPostReactions() {
    _adminPostReactionCounts.clear();
    _myAdminPostReaction.clear();
    for (final p in matangazoPosts) {
      _adminPostReactionCounts[p.id] = {
        for (final k in kCommunityReactionKinds) k.key: 0,
      };
    }
    _adminPostReactionCounts['post-msiba']!['cry'] = 28;
    _adminPostReactionCounts['post-msiba']!['love'] = 16;
    _adminPostReactionCounts['post-msiba']!['like'] = 9;
    _adminPostReactionCounts['post-msiba']!['fire'] = 3;
    _adminPostReactionCounts['post-sherehe']!['fire'] = 12;
    _adminPostReactionCounts['post-sherehe']!['love'] = 24;
    _adminPostReactionCounts['post-sherehe']!['hungry'] = 5;
    _adminPostReactionCounts['post-mkutano']!['like'] = 7;
    _adminPostReactionCounts['post-mkutano']!['cry'] = 2;
  }

  /// Survives hot reload when [AppState] is kept but maps were cleared / IDs changed.
  void _ensureAdminPostReactions(String postId) {
    if (_adminPostReactionCounts.containsKey(postId)) return;
    _adminPostReactionCounts[postId] = {
      for (final k in kCommunityReactionKinds) k.key: 0,
    };
  }

  Map<String, int> adminPostReactionCounts(String postId) {
    _ensureAdminPostReactions(postId);
    return _adminPostReactionCounts[postId]!;
  }

  String? myAdminPostReaction(String postId) => _myAdminPostReaction[postId];

  /// One reaction per user per post (tap again to remove), Telegram-style.
  void toggleAdminPostReaction(String postId, String reactionKey) {
    _ensureAdminPostReactions(postId);
    final counts = _adminPostReactionCounts[postId]!;
    if (!counts.containsKey(reactionKey)) return;
    final prev = _myAdminPostReaction[postId];
    if (prev == reactionKey) {
      counts[reactionKey] = (counts[reactionKey]! - 1).clamp(0, 999999);
      _myAdminPostReaction[postId] = null;
    } else {
      if (prev != null) {
        counts[prev] = (counts[prev]! - 1).clamp(0, 999999);
      }
      counts[reactionKey] = (counts[reactionKey]! + 1);
      _myAdminPostReaction[postId] = reactionKey;
    }
    notifyListeners();
  }

  List<ChatMsg> get currentChatMessages =>
      chatTarget == 'admin' ? messagesAdmin : messagesCommunity;

  void setScreen(AppScreen s) {
    screen = s;
    if (s == AppScreen.main || s == AppScreen.pendingApproval || s == AppScreen.adminMain) {
      _startAutoRefresh();
    }
    notifyListeners();
  }

  void setOnboardStep(int i) {
    onboardStep = i.clamp(0, onboardSlides.length - 1);
    notifyListeners();
  }

  void setRegStep(int s) {
    regStep = s.clamp(1, 4);
    notifyListeners();
  }

  void saveRegField(String id, String value) {
    regData[id] = value;
    notifyListeners();
  }

  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }

  void setMainTab(int semanticIndex) {
    final s = semanticIndex.clamp(0, 3);
    if (!enabledUserTabIndices.contains(s)) {
      ensureUserMainTabValid();
      return;
    }
    mainTabIndex = s;
    notifyListeners();
  }

  void setCommunitySection(int i) {
    communitySection = i;
    if (i <= 1) {
      chatTarget = i == 0 ? 'community' : 'admin';
    }
    notifyListeners();
  }

  void setChatTarget(String t) {
    chatTarget = t;
    notifyListeners();
  }

  Future<bool> sendCommunityMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    if (adminJwt != null && adminJwt!.isNotEmpty) {
      return adminSendCommunityMessageApi(trimmed);
    }
    if (!canCurrentUserPostCommunityChat) return false;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final tok = memberJwt;
    if (tok == null || tok.isEmpty) return false;
    try {
      await NyihaApi.post('/chat/community', {
        'fromLabel': user.name,
        'text': trimmed,
        'timeLabel': time,
        'emoji': '👤',
        'mediaKind': 'text',
      }, bearer: tok);
      await fetchCommunityChatsApi();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchManagedMembersApi() async {
    final tok = adminJwt;
    if (tok == null || tok.isEmpty) return false;
    try {
      final rows = await NyihaApi.getList('/admin/members', bearer: tok);
      managedMembers
        ..clear()
        ..addAll(
          rows.whereType<Map<String, dynamic>>().map((m) {
            final statusRaw = (m['status']?.toString() ?? 'pending').toLowerCase();
            final status = switch (statusRaw) {
              'approved' => MemberStatus.approved,
              'suspended' => MemberStatus.suspended,
              _ => MemberStatus.pending,
            };
            return ManagedMember(
              id: m['id']?.toString(),
              name: m['name']?.toString() ?? '',
              phone: m['phone']?.toString() ?? '',
              location: m['location']?.toString() ?? '',
              ticks: (m['ticksPaid'] is num) ? (m['ticksPaid'] as num).toInt() : 0,
              emoji: m['emoji']?.toString() ?? '👤',
              status: status,
              adminProfileNote: m['adminProfileNote']?.toString() ?? '',
              adminWarning: m['adminWarning']?.toString() ?? '',
              balanceTzs: (m['balance'] is num) ? (m['balance'] as num).toInt() : 0,
            );
          }).where((x) => x.name.isNotEmpty),
        );
      notifyListeners();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchMemberDirectoryApi() async {
    final tok = memberJwt;
    if (tok == null || tok.isEmpty) return false;
    try {
      final rows = await NyihaApi.getList('/member/members', bearer: tok);
      managedMembers
        ..clear()
        ..addAll(
          rows.whereType<Map<String, dynamic>>().map((m) {
            final statusRaw = (m['status']?.toString() ?? 'pending').toLowerCase();
            final status = switch (statusRaw) {
              'approved' => MemberStatus.approved,
              'suspended' => MemberStatus.suspended,
              _ => MemberStatus.pending,
            };
            return ManagedMember(
              id: m['id']?.toString(),
              name: m['name']?.toString() ?? '',
              phone: m['phone']?.toString() ?? '',
              location: m['location']?.toString() ?? '',
              ticks: (m['ticksPaid'] is num) ? (m['ticksPaid'] as num).toInt() : 0,
              emoji: '👤',
              status: status,
              adminProfileNote: '',
              adminWarning: '',
              balanceTzs: 0,
            );
          }).where((x) => x.name.isNotEmpty),
        );
      notifyListeners();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  bool profileAvatarUploading = false;

  /// `POST /me/avatar` then refresh profile and community chat so avatars match.
  Future<bool> uploadMemberAvatar(Uint8List bytes, {String filename = 'avatar.jpg'}) async {
    final tok = memberJwt;
    if (tok == null || tok.isEmpty) return false;
    if (bytes.isEmpty) return false;
    profileAvatarUploading = true;
    notifyListeners();
    try {
      await NyihaApi.uploadMemberAvatar(bytes: bytes, filename: filename, bearer: tok);
      final me = await NyihaApi.getMap('/me', bearer: tok);
      _applyUserJson(me);
      lastApiError = null;
      await fetchCommunityChatsApi();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    } finally {
      profileAvatarUploading = false;
      notifyListeners();
    }
  }

  Future<bool> fetchCommunityChatsApi() async {
    final tok = memberJwt ?? adminJwt;
    if (tok == null || tok.isEmpty) return false;
    try {
      final rows = await NyihaApi.getList('/chat/community?limit=200', bearer: tok);
      messagesCommunity
        ..clear()
        ..addAll(
          rows.whereType<Map<String, dynamic>>().map((m) {
            final kind = _parseChatMediaKind(m['mediaKind']);
            return ChatMsg(
              from: m['fromLabel']?.toString() ?? 'Unknown',
              text: m['text']?.toString() ?? '',
              time: m['timeLabel']?.toString() ?? '',
              me: _communityMsgIsFromViewer(m),
              emoji: m['emoji']?.toString(),
              kind: kind,
              imageUrl: m['imageUrl']?.toString(),
              voiceUrl: m['voiceUrl']?.toString(),
              voiceDurationSec: (m['voiceDurationSec'] is num) ? (m['voiceDurationSec'] as num).toInt() : null,
              avatarUrl: m['avatarUrl']?.toString(),
            );
          }),
        );
      notifyListeners();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  ChatMediaKind _parseChatMediaKind(dynamic v) {
    final s = v?.toString().toLowerCase();
    if (s == 'image') return ChatMediaKind.image;
    if (s == 'voice') return ChatMediaKind.voice;
    return ChatMediaKind.text;
  }

  bool _communityMsgIsFromViewer(Map<String, dynamic> m) {
    if (memberJwt != null && memberJwt!.isNotEmpty) {
      return m['isFromMe'] == true;
    }
    if (adminJwt != null && adminSession != null) {
      final label = m['fromLabel']?.toString() ?? '';
      return label == adminSession!.displayName;
    }
    return false;
  }

  Future<bool> sendCommunityImage(Uint8List bytes, {String caption = ''}) async {
    if (!canPostCommunityMedia) return false;
    if (bytes.isEmpty) return false;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final cap = caption.trim();
    final tok = memberJwt ?? adminJwt;
    if (tok == null || tok.isEmpty) return false;
    try {
      final storedPath = await NyihaApi.uploadChatBytes(
        bytes: bytes,
        filename: 'chat_${now.millisecondsSinceEpoch}.jpg',
        bearer: tok,
      );
      if (storedPath == null || storedPath.isEmpty) return false;

      if (adminJwt != null && adminJwt!.isNotEmpty) {
        await NyihaApi.post('/admin/chat/community', {
          'text': cap,
          'timeLabel': time,
          'emoji': '🛡️',
          'mediaKind': 'image',
          'imageUrl': storedPath,
        }, bearer: adminJwt);
      } else {
        await NyihaApi.post('/chat/community', {
          'fromLabel': user.name,
          'text': cap,
          'timeLabel': time,
          'emoji': '👤',
          'mediaKind': 'image',
          'imageUrl': storedPath,
        }, bearer: memberJwt);
      }
      await fetchCommunityChatsApi();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendCommunityVoice({required String filePath, required int durationSec}) async {
    if (!canPostCommunityMedia) return false;
    if (durationSec < 1 || filePath.isEmpty) return false;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final tok = memberJwt ?? adminJwt;
    if (tok == null || tok.isEmpty) return false;
    try {
      final storedPath = await NyihaApi.uploadChatFilePath(
        path: filePath,
        filename: 'voice_${now.millisecondsSinceEpoch}.m4a',
        bearer: tok,
      );
      if (storedPath == null || storedPath.isEmpty) return false;

      if (adminJwt != null && adminJwt!.isNotEmpty) {
        await NyihaApi.post('/admin/chat/community', {
          'text': '',
          'timeLabel': time,
          'emoji': '🛡️',
          'mediaKind': 'voice',
          'voiceUrl': storedPath,
          'voiceDurationSec': durationSec,
        }, bearer: adminJwt);
      } else {
        await NyihaApi.post('/chat/community', {
          'fromLabel': user.name,
          'text': '',
          'timeLabel': time,
          'emoji': '👤',
          'mediaKind': 'voice',
          'voiceUrl': storedPath,
          'voiceDurationSec': durationSec,
        }, bearer: memberJwt);
      }
      await fetchCommunityChatsApi();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  /// Wanachama DM — keyed by member full name ([MockMember.name]).
  final Map<String, List<ChatMsg>> _privateChatsByMemberName = {};

  List<ChatMsg> privateMessagesFor(String memberName) {
    return _privateChatsByMemberName.putIfAbsent(memberName, () => []);
  }

  void sendPrivateMessage({
    required String memberName,
    required String memberEmoji,
    required String text,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (memberName == user.name) return;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final list = _privateChatsByMemberName.putIfAbsent(memberName, () => []);
    list.add(ChatMsg(from: 'You', text: trimmed, time: time, me: true));
    notifyListeners();

    Future<void>.delayed(const Duration(milliseconds: 900), () {
      final cur = _privateChatsByMemberName[memberName];
      if (cur == null || cur.isEmpty) return;
      final t2 =
          '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      final replies = [
        'Nimepokea ujumbe wako. Nitajibu hivi punde.',
        'Asante! Nimeona. Tunaweza kuendelea hapa.',
        'Sawa, nimeelewa. Karibu tuwasiliane.',
        'Hongera! Nitakupigia au nitajibu hapa.',
      ];
      cur.add(
        ChatMsg(
          from: memberName.split(' ').first,
          text: replies[_rng.nextInt(replies.length)],
          time: t2,
          me: false,
          emoji: memberEmoji,
        ),
      );
      notifyListeners();
    });
  }

  void sendSellerMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    messagesSeller.add(ChatMsg(from: 'You', text: trimmed, time: time, me: true));
    notifyListeners();

    // Demo “live” reply — replace with WebSocket / backend later.
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      final t2 =
          '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      final replies = [
        'Asante! Nimeona ujumbe wako. Nitawasiliana kwa simu au hapa.',
        'Sawa. Malipo yanaweza kwa M-Pesa — nitakutumia nambari baada ya uhakiki.',
        'Hongera! Tutathibitisha oda na kukujulisha hatua inayofuata.',
        'Niko hapa. Je, ungependa tukutumie picha ya bidhaa kabla ya malipo?',
      ];
      messagesSeller.add(
        ChatMsg(
          from: 'Muuzaji Duka',
          text: replies[_rng.nextInt(replies.length)],
          time: t2,
          me: false,
          emoji: '🛍️',
        ),
      );
      notifyListeners();
    });
  }

  void votePoll(int pollIndex, int optionIndex) {
    final p = polls[pollIndex];
    if (p.voted) return;
    p.voted = true;
    p.votedIdx = optionIndex;
    p.options[optionIndex].v += 1;
    notifyListeners();
  }

  void applyRegistrationToUser() {
    user.name = regData['r-name'] ?? user.name;
    user.phone = regData['r-phone'] ?? user.phone;
    user.email = regData['r-email'] ?? user.email;
    user.location = regData['r-location'] ?? user.location;
    user.username = regData['r-username'] ?? user.username;
    final cc = int.tryParse(regData['r-children'] ?? '');
    if (cc != null) user.children = cc;
    notifyListeners();
  }

  /// Only users with status `Approved` may use the main member app.
  bool get isMemberApproved => user.status.trim().toLowerCase() == 'approved';

  /// After registration form + ada lipa — user stays Pending until admin approves.
  void completeRegistrationPendingApproval() {
    applyRegistrationToUser();
    user.status = 'Pending';
    final now = DateTime.now();
    final id = 'req-${now.millisecondsSinceEpoch}';
    final buf = StringBuffer()
      ..writeln('Jina: ${user.name}')
      ..writeln('Simu: ${user.phone}')
      ..writeln('Makazi: ${user.location}')
      ..writeln('Mtumiaji: @${user.username}')
      ..writeln('Watoto: ${user.children}');
    pendingSignupRequests.insert(
      0,
      PendingSignupRequest(
        id: id,
        fullName: user.name,
        phone: user.phone,
        location: user.location,
        username: user.username,
        children: user.children,
        submittedAt: now,
        registrationFeePaid: true,
        detailLines: buf.toString(),
      ),
    );
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    messagesAdmin.insert(
      0,
      ChatMsg(
        from: 'Maombi',
        text:
            'Mwanachama mpya: ${user.name} (${user.phone}) — ada imekwisha lipwa (demo). Hakikisha malipo halisi kabla ya kuidhinisha.',
        time: time,
        me: false,
        emoji: '📝',
      ),
    );
    notifyListeners();
  }

  void approveSignupRequest(String requestId) {
    if (adminJwt != null && adminJwt!.isNotEmpty) {
      approveSignupRequestApi(requestId);
      return;
    }
    final idx = pendingSignupRequests.indexWhere((r) => r.id == requestId);
    if (idx < 0) return;
    final r = pendingSignupRequests.removeAt(idx);
    user.status = 'Approved';
    if (!managedMembers.any((m) => m.phone == r.phone)) {
      managedMembers.insert(
        0,
        ManagedMember(
          name: r.fullName,
          phone: r.phone,
          location: r.location,
          ticks: 0,
          emoji: '👤',
          status: MemberStatus.approved,
        ),
      );
    }
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    messagesAdmin.insert(
      0,
      ChatMsg(
        from: 'Admin',
        text: 'Ombi la ${r.fullName} limeidhinishwa. Karibu kwenye Jamii ya Nyiha.',
        time: time,
        me: false,
        emoji: '✅',
      ),
    );
    notifyListeners();
  }

  void rejectSignupRequest(String requestId) {
    if (adminJwt != null && adminJwt!.isNotEmpty) {
      rejectSignupRequestApi(requestId);
      return;
    }
    final idx = pendingSignupRequests.indexWhere((r) => r.id == requestId);
    if (idx < 0) return;
    pendingSignupRequests.removeAt(idx);
    user.status = 'Rejected';
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    messagesAdmin.insert(
      0,
      ChatMsg(
        from: 'Admin',
        text: 'Ombi la uanachama limekataliwa (${user.name}).',
        time: time,
        me: false,
        emoji: '⛔',
      ),
    );
    notifyListeners();
  }

  void setCustomerCare({String? phone, String? whatsapp, String? hoursLabel}) {
    if (phone != null) customerCarePhone = phone.trim();
    if (whatsapp != null) customerCareWhatsApp = whatsapp.trim();
    if (hoursLabel != null) customerCareHoursLabel = hoursLabel.trim();
    notifyListeners();
  }

  int get ticksOwedAnnual =>
      (ticksRequiredAnnualSetting - user.ticksPaid).clamp(0, ticksRequiredAnnualSetting);

  /// Starts payment request (M-Pesa etc.); blocks if one is already in flight.
  bool submitTickPaymentRequest(int tickCount) {
    if (pendingTickPayment != null) return false;
    final owed = ticksOwedAnnual;
    if (tickCount < 1 || tickCount > owed) return false;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    pendingTickPayment = PendingTickPayment(
      id: 'TK-${now.millisecondsSinceEpoch}',
      tickCount: tickCount,
      submittedAt: now,
    );
    messagesAdmin.insert(
      0,
      ChatMsg(
        from: 'Malipo',
        text:
            'Ombi la malipo: ${user.name} anaomba kulipa tiki $tickCount (TZS ${tickCount * tickPriceTzsSetting}). Nambari: ${pendingTickPayment!.id}. Hali: inasubiri malipo.',
        time: time,
        me: false,
        emoji: '💳',
      ),
    );
    notifyListeners();
    return true;
  }

  /// User confirms money left their phone / received by paybill (demo step).
  void confirmTickMoneyReceived() {
    final p = pendingTickPayment;
    if (p == null || p.phase != TickPaymentPhase.waitingMoney) return;
    p.phase = TickPaymentPhase.waitingAdminApproval;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    messagesAdmin.insert(
      0,
      ChatMsg(
        from: 'Malipo',
        text:
            'Malipo ya tiki ${p.tickCount} yamepokelewa kwa akaunti ya jamii. Inasubiri uidhinishaji wa admin. (${user.name})',
        time: time,
        me: false,
        emoji: '✅',
      ),
    );
    notifyListeners();
  }

  /// Admin confirms (replace with backend / admin app).
  void adminApprovePendingTickPayment() {
    final p = pendingTickPayment;
    if (p == null || p.phase != TickPaymentPhase.waitingAdminApproval) return;
    final n = p.tickCount;
    user.ticksPaid += n;
    pendingTickPayment = null;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    messagesAdmin.insert(
      0,
      ChatMsg(
        from: 'Admin',
        text:
            'Malipo ya tiki $n yameidhinishwa. ${user.name} sasa ana tiki ${user.ticksPaid} kati ya $ticksRequiredAnnualSetting.',
        time: time,
        me: false,
        emoji: '⚡',
      ),
    );
    notifyListeners();
  }

  final List<PlacedShopOrder> shopOrders = [];

  /// Submits order to seller (demo: logs on admin channel).
  void placeShopOrder({
    required MockProduct product,
    required String size,
    required String rangi,
    required int idadi,
  }) {
    final now = DateTime.now();
    final orderId = 'oda-${now.millisecondsSinceEpoch}';
    shopOrders.insert(
      0,
      PlacedShopOrder(
        id: orderId,
        productName: product.name,
        priceLabel: product.priceLabel,
        size: size,
        rangi: rangi,
        idadi: idadi,
        placedAt: now,
        buyerName: user.name,
      ),
    );
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final summary =
        'Oda mpya: ${product.name} — saizi $size, rangi $rangi, idadi $idadi (${product.priceLabel}). Mteja: ${user.name}. Hali: inasubiri malipo.';
    messagesAdmin.insert(
      0,
      ChatMsg(from: 'Muuzaji / Duka', text: summary, time: time, me: false, emoji: '🛍️'),
    );
    messagesSeller.insert(
      0,
      ChatMsg(
        from: 'Muuzaji Duka',
        text:
            'Habari ${user.name}! Nimepokea oda yako ya "${product.name}" (saizi $size, $rangi, ×$idadi). Oda inasubiri malipo — andika hapa ikiwa una swali.',
        time: time,
        me: false,
        emoji: '🛍️',
      ),
    );
    notifyListeners();
  }

  // —— API (Railway backend) ——

  Future<void> saveMemberJwt(String? jwt) async {
    memberJwt = jwt;
    if (jwt == null || jwt.isEmpty) {
      await _secure.delete(key: _kMemberJwt);
    } else {
      await _secure.write(key: _kMemberJwt, value: jwt);
    }
    notifyListeners();
  }

  Future<void> saveAdminJwt(String? jwt) async {
    adminJwt = jwt;
    if (jwt == null || jwt.isEmpty) {
      await _secure.delete(key: _kAdminJwt);
    } else {
      await _secure.write(key: _kAdminJwt, value: jwt);
    }
    notifyListeners();
  }

  /// Splash / cold start: restore session and catalog, or go onboarding / login.
  Future<void> bootstrapSession() async {
    lastApiError = null;
    memberJwt = await _secure.read(key: _kMemberJwt);
    if (memberJwt == null || memberJwt!.isEmpty) {
      setScreen(AppScreen.onboarding);
      return;
    }
    try {
      final me = await NyihaApi.getMap('/me', bearer: memberJwt);
      _applyUserJson(me);
      setScreen(isMemberApproved ? AppScreen.main : AppScreen.pendingApproval);
      unawaited(triggerFastRefresh(force: true));
    } catch (_) {
      await saveMemberJwt(null);
      setScreen(AppScreen.login);
    }
  }

  void _applyUserJson(Map<String, dynamic> j) {
    user.name = j['name']?.toString() ?? user.name;
    user.phone = j['phone']?.toString() ?? user.phone;
    final av = j['avatarUrl']?.toString();
    user.avatarUrl = (av != null && av.trim().isNotEmpty) ? av.trim() : null;
    user.email = j['email']?.toString() ?? user.email;
    user.location = j['location']?.toString() ?? user.location;
    user.children = (j['children'] is num) ? (j['children'] as num).toInt() : user.children;
    user.status = j['status']?.toString() ?? user.status;
    user.ticksPaid = (j['ticksPaid'] is num) ? (j['ticksPaid'] as num).toInt() : user.ticksPaid;
    user.balance = (j['balance'] is num) ? (j['balance'] as num).toInt() : user.balance;
    user.username = j['username']?.toString() ?? user.username;
    user.adminProfileNote = j['adminProfileNote']?.toString() ?? '';
    user.adminWarning = j['adminWarning']?.toString() ?? '';
    if (j['ticksRequiredAnnual'] is num) {
      ticksRequiredAnnualSetting = (j['ticksRequiredAnnual'] as num).toInt();
    }
    if (j['tickPriceTzs'] is num) {
      tickPriceTzsSetting = (j['tickPriceTzs'] as num).toInt();
    }
    notifyListeners();
  }

  Future<bool> registerWithApi() async {
    lastApiError = null;
    final email = regData['r-email']?.trim() ?? '';
    final pass = regData['r-pass'] ?? '';
    if (email.isEmpty || !email.contains('@')) {
      lastApiError = 'Weka barua pepe halali.';
      notifyListeners();
      return false;
    }
    if (pass.length < 8) {
      lastApiError = 'Nenosiri lazima liwe angalau herufi 8.';
      notifyListeners();
      return false;
    }
    final detail = StringBuffer()
      ..writeln('Baba: ${regData['r-father'] ?? ''}')
      ..writeln('Mama: ${regData['r-mother'] ?? ''}')
      ..writeln('Jamaa: ${regData['r-relatives'] ?? ''}')
      ..writeln('Rufaa: ${regData['r-referral'] ?? ''}');
    try {
      final body = <String, dynamic>{
        'name': regData['r-name'] ?? '',
        'email': email,
        'phone': regData['r-phone'] ?? '',
        'location': regData['r-location'] ?? '',
        'children': int.tryParse(regData['r-children'] ?? '0') ?? 0,
        'username': regData['r-username'] ?? '',
        'password': pass,
        'detailLines': detail.toString(),
      };
      final res = await NyihaApi.post('/auth/register', body);
      final tok = res['token']?.toString();
      if (tok == null || tok.isEmpty) {
        lastApiError = 'Jibu la seva silinganifu.';
        notifyListeners();
        return false;
      }
      await saveMemberJwt(tok);
      final u = res['user'];
      if (u is Map<String, dynamic>) _applyUserJson(u);
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  String _formatApiError(Object e) {
    if (e is ApiException) return e.message;
    return e.toString();
  }

  Future<bool> loginMemberApi(String identifier, String password) async {
    lastApiError = null;
    try {
      final id = identifier.trim();
      final idLower = id.toLowerCase();
      final res = await NyihaApi.post('/auth/login', {
        // Support both current and legacy backend contracts.
        'identifier': id,
        'phone': id,
        'email': idLower,
        'username': idLower,
        'password': password,
      });
      final tok = res['token']?.toString();
      if (tok == null || tok.isEmpty) return false;
      await saveMemberJwt(tok);
      final u = res['user'];
      if (u is Map<String, dynamic>) _applyUserJson(u);
      _startAutoRefresh();
      unawaited(triggerFastRefresh(force: true));
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestPasswordResetEmail(String email) async {
    lastApiError = null;
    try {
      await NyihaApi.post('/auth/forgot-password', {'email': email.trim().toLowerCase()});
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPasswordWithToken(String token, String newPassword) async {
    lastApiError = null;
    try {
      await NyihaApi.post('/auth/reset-password', {
        'token': token.trim(),
        'newPassword': newPassword,
      });
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginAdminApi(String email, String password) async {
    lastApiError = null;
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final res = await NyihaApi.post('/auth/admin/login', {
        // Keep compatibility with older backend payload contracts.
        'email': normalizedEmail,
        'identifier': normalizedEmail,
        'pin': password,
        'password': password,
      });
      final tok = res['token']?.toString();
      final adm = res['admin'];
      if (tok == null || adm is! Map<String, dynamic>) return false;
      await saveAdminJwt(tok);
      final roleStr = adm['role']?.toString() ?? 'helper';
      adminSession = AdminAccount(
        id: adm['id']?.toString() ?? 'adm',
        displayName: adm['displayName']?.toString() ?? 'Admin',
        email: adm['email']?.toString() ?? email,
        role: roleStr == 'main' ? AdminRole.main : AdminRole.helper,
        pin: '',
        linkedMemberPhone: adm['linkedMemberPhone']?.toString(),
      );
      _startAutoRefresh();
      unawaited(Future.wait([
        fetchPendingSignupsApi(),
        fetchManagedMembersApi(),
        fetchCommunityChatsApi(),
      ]));
      notifyListeners();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchPendingSignupsApi() async {
    final tok = adminJwt;
    if (tok == null || tok.isEmpty) return false;
    try {
      final list = await NyihaApi.getList('/admin/signups/pending', bearer: tok);
      pendingSignupRequests
        ..clear()
        ..addAll(
          list.whereType<Map<String, dynamic>>().map((m) {
            final submittedAtRaw = m['submittedAt']?.toString();
            final submittedAt = submittedAtRaw == null
                ? DateTime.now()
                : DateTime.tryParse(submittedAtRaw) ?? DateTime.now();
            return PendingSignupRequest(
              id: m['id']?.toString() ?? '',
              fullName: m['fullName']?.toString() ?? '',
              phone: m['phone']?.toString() ?? '',
              location: m['location']?.toString() ?? '',
              username: m['username']?.toString() ?? '',
              children: (m['children'] is num) ? (m['children'] as num).toInt() : 0,
              submittedAt: submittedAt,
              registrationFeePaid: m['registrationFeePaid'] as bool? ?? false,
              detailLines: m['detailLines']?.toString() ?? '',
            );
          }).where((x) => x.id.isNotEmpty),
        );
      notifyListeners();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> approveSignupRequestApi(String requestId) async {
    final tok = adminJwt;
    if (tok == null || tok.isEmpty) return false;
    try {
      await NyihaApi.post('/admin/signups/$requestId/approve', const {}, bearer: tok);
      pendingSignupRequests.removeWhere((r) => r.id == requestId);
      await fetchManagedMembersApi();
      notifyListeners();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectSignupRequestApi(String requestId) async {
    final tok = adminJwt;
    if (tok == null || tok.isEmpty) return false;
    try {
      await NyihaApi.post('/admin/signups/$requestId/reject', const {}, bearer: tok);
      pendingSignupRequests.removeWhere((r) => r.id == requestId);
      await fetchManagedMembersApi();
      notifyListeners();
      return true;
    } catch (e) {
      lastApiError = _formatApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logoutMember() async {
    await saveMemberJwt(null);
    _stopAutoRefresh();
    notifyListeners();
  }

  Future<void> refreshRemoteCatalog() async {
    final b = memberJwt;
    if (b != null && b.isNotEmpty) {
      try {
        final me = await NyihaApi.getMap('/me', bearer: b);
        _applyUserJson(me);
      } catch (_) {
        /* keep profile if /me fails transiently */
      }
    }
    try {
      final proms = await Future.wait([
        NyihaApi.getList('/products', bearer: b),
        NyihaApi.getList('/posts', bearer: b),
        NyihaApi.getList('/events', bearer: b),
        NyihaApi.getMap('/settings', bearer: b),
      ]);
      final plist = proms[0] as List<dynamic>;
      final postlist = proms[1] as List<dynamic>;
      final evlist = proms[2] as List<dynamic>;
      final settings = proms[3] as Map<String, dynamic>;

      dukaProducts = plist.map((raw) {
        final m = raw as Map<String, dynamic>;
        final c = (m['color'] is num) ? (m['color'] as num).toInt() : 0xffd4a017;
        return MockProduct(
          apiId: m['id']?.toString(),
          name: m['name']?.toString() ?? '',
          priceLabel: m['priceLabel']?.toString() ?? '',
          emoji: m['emoji']?.toString() ?? '🛍️',
          color: c,
          imageUrl: m['imageUrl']?.toString() ?? '',
        );
      }).toList();

      matangazoPosts = postlist.map((raw) {
        final m = raw as Map<String, dynamic>;
        final urls = m['imageUrls'];
        final list = <String>[];
        if (urls is List) {
          for (final u in urls) {
            if (u != null) list.add(u.toString());
          }
        }
        return AdminCommunityPost(
          id: m['id']?.toString() ?? '',
          authorLabel: m['authorLabel']?.toString() ?? '',
          headline: m['headline']?.toString() ?? '',
          body: m['body']?.toString() ?? '',
          dateLabel: m['dateLabel']?.toString() ?? '',
          tag: m['tag']?.toString() ?? '',
          imageUrls: list,
        );
      }).toList();

      jamiiEvents = evlist.map((raw) {
        final m = raw as Map<String, dynamic>;
        return MockEvent(
          title: m['title']?.toString() ?? '',
          desc: m['desc']?.toString() ?? '',
          date: m['date']?.toString() ?? '',
          tag: m['tag']?.toString() ?? '',
        );
      }).toList();

      customerCarePhone = settings['customerCarePhone']?.toString() ?? customerCarePhone;
      customerCareWhatsApp = settings['customerCareWhatsApp']?.toString() ?? customerCareWhatsApp;
      customerCareHoursLabel = settings['customerCareHoursLabel']?.toString() ?? customerCareHoursLabel;
      showUserTabHome = settings['showUserTabHome'] as bool? ?? showUserTabHome;
      showUserTabJamii = settings['showUserTabJamii'] as bool? ?? showUserTabJamii;
      showUserTabDuka = settings['showUserTabDuka'] as bool? ?? showUserTabDuka;
      showUserTabProfile = settings['showUserTabProfile'] as bool? ?? showUserTabProfile;
      showJamiiMazungumzo = settings['showJamiiMazungumzo'] as bool? ?? showJamiiMazungumzo;
      showJamiiAdminChat = settings['showJamiiAdminChat'] as bool? ?? showJamiiAdminChat;
      showJamiiWanachama = settings['showJamiiWanachama'] as bool? ?? showJamiiWanachama;
      showJamiiMatukio = settings['showJamiiMatukio'] as bool? ?? showJamiiMatukio;
      showJamiiMkeka = settings['showJamiiMkeka'] as bool? ?? showJamiiMkeka;
      showJamiiKura = settings['showJamiiKura'] as bool? ?? showJamiiKura;
      jamiiCommunityChatMembersCanSend =
          settings['jamiiCommunityChatMembersCanSend'] as bool? ?? jamiiCommunityChatMembersCanSend;
      final tra = settings['ticksRequiredAnnual'];
      if (tra is num) ticksRequiredAnnualSetting = tra.toInt();
      final tpr = settings['tickPriceTzs'];
      if (tpr is num) tickPriceTzsSetting = tpr.toInt();

      notifyListeners();
      await fetchMemberDirectoryApi();
      await fetchCommunityChatsApi();
    } catch (_) {
      /* keep cached mock data */
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      unawaited(triggerFastRefresh());
    });
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  bool _isStale(DateTime? t, Duration maxAge) {
    if (t == null) return true;
    return DateTime.now().difference(t) > maxAge;
  }

  Future<void> triggerFastRefresh({bool force = false}) async {
    if (_refreshInFlight) return;
    _refreshInFlight = true;
    try {
      final tasks = <Future<void>>[];
      if (memberJwt != null && memberJwt!.isNotEmpty) {
        if (force || _isStale(_lastCatalogRefreshAt, const Duration(seconds: 60))) {
          tasks.add(
            refreshRemoteCatalog().then((_) {
              _lastCatalogRefreshAt = DateTime.now();
            }),
          );
        }
        if (force || _isStale(_lastMembersRefreshAt, const Duration(seconds: 60))) {
          tasks.add(
            fetchMemberDirectoryApi().then((ok) {
              if (ok) _lastMembersRefreshAt = DateTime.now();
            }),
          );
        }
      }
      if ((memberJwt != null && memberJwt!.isNotEmpty) || (adminJwt != null && adminJwt!.isNotEmpty)) {
        if (force || _isStale(_lastChatsRefreshAt, const Duration(seconds: 15))) {
          tasks.add(
            fetchCommunityChatsApi().then((ok) {
              if (ok) _lastChatsRefreshAt = DateTime.now();
            }),
          );
        }
      }
      if (adminJwt != null && adminJwt!.isNotEmpty) {
        if (force || _isStale(_lastMembersRefreshAt, const Duration(seconds: 60))) {
          tasks.add(
            fetchManagedMembersApi().then((ok) {
              if (ok) _lastMembersRefreshAt = DateTime.now();
            }),
          );
        }
        tasks.add(fetchPendingSignupsApi().then((_) {}));
      }
      if (tasks.isNotEmpty) {
        await Future.wait(tasks);
      }
    } finally {
      _refreshInFlight = false;
    }
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }
}
