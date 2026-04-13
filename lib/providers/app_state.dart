import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/admin_models.dart';
import '../models/models.dart';

enum AppScreen {
  splash,
  onboarding,
  register,
  terms,
  payment,
  login,
  main,
  pendingApproval,
  adminLogin,
  adminMain,
}

class AppState extends ChangeNotifier {
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
      displayName: 'Mkuu wa Wasimamizi',
      email: 'mkuu@nyiha.app',
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
    location: 'Dar es Salaam',
    children: 2,
    status: 'Approved',
    ticksPaid: 12,
    balance: 2000,
    username: 'lulez_nyiha',
  );

  /// Target tiki for the year (Mkeka).
  static const int ticksRequiredAnnual = 24;
  /// TZS per tiki (demo).
  static const int tickPriceTzs = 2000;

  PendingTickPayment? pendingTickPayment;

  String chatTarget = 'community';
  final List<ChatMsg> messagesCommunity = [];
  final List<ChatMsg> messagesAdmin = [];
  /// Buyer ↔ duka seller (from cart / oda flow).
  final List<ChatMsg> messagesSeller = [];

  final Random _rng = Random();

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

  void logoutAdmin() {
    adminSession = null;
    adminShellIndex = 0;
    notifyListeners();
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

  void sendCommunityMessage(String text) {
    if (!canCurrentUserPostCommunityChat) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    messagesCommunity.add(
      ChatMsg(from: 'You', text: trimmed, time: time, me: true, kind: ChatMediaKind.text),
    );
    notifyListeners();
  }

  void sendCommunityImage(Uint8List bytes, {String caption = ''}) {
    if (!canCurrentUserPostCommunityChat) return;
    if (bytes.isEmpty) return;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    messagesCommunity.add(
      ChatMsg(
        from: 'You',
        text: caption.trim(),
        time: time,
        me: true,
        kind: ChatMediaKind.image,
        imageBytes: bytes,
      ),
    );
    notifyListeners();
  }

  void sendCommunityVoice({required String filePath, required int durationSec}) {
    if (!canCurrentUserPostCommunityChat) return;
    if (durationSec < 1 || filePath.isEmpty) return;
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    messagesCommunity.add(
      ChatMsg(
        from: 'You',
        text: '',
        time: time,
        me: true,
        kind: ChatMediaKind.voice,
        voiceFilePath: filePath,
        voiceDurationSec: durationSec,
      ),
    );
    notifyListeners();
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
      (ticksRequiredAnnual - user.ticksPaid).clamp(0, ticksRequiredAnnual);

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
            'Ombi la malipo: ${user.name} anaomba kulipa tiki $tickCount (TZS ${tickCount * tickPriceTzs}). Nambari: ${pendingTickPayment!.id}. Hali: inasubiri malipo.',
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
            'Malipo ya tiki $n yameidhinishwa. ${user.name} sasa ana tiki ${user.ticksPaid} kati ya $ticksRequiredAnnual.',
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
}
