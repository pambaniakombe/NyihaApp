import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart' show AppState, AppScreen;
import '../../services/nyiha_api.dart';
import '../lipa_tiki_screen.dart';
import '../../theme/nyiha_colors.dart';
import '../../theme/nyiha_text.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kente_strip.dart';
import '../../widgets/nyiha_buttons.dart';
import '../../widgets/nyiha_toast.dart';
import '../matangazo_screen.dart';

Future<void> _pickProfilePhoto(BuildContext context, AppState app) async {
  if (app.memberJwt == null || app.memberJwt!.isEmpty) {
    showNyihaToast(context, 'Ingia ili kubadilisha picha ya profaili.');
    return;
  }
  final picker = ImagePicker();
  final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 88);
  if (x == null || !context.mounted) return;
  final bytes = await x.readAsBytes();
  if (!context.mounted) return;
  final fn = x.name.toLowerCase();
  final filename = fn.endsWith('.png')
      ? x.name
      : fn.endsWith('.webp')
          ? x.name
          : fn.endsWith('.gif')
              ? x.name
              : 'avatar.jpg';
  final ok = await app.uploadMemberAvatar(bytes, filename: filename);
  if (!context.mounted) return;
  if (ok) {
    showNyihaToast(context, 'Picha ya profaili imesasishwa.');
  } else if (app.lastApiError != null) {
    showNyihaToast(context, app.lastApiError!);
  }
}

Widget _profileAvatarInner(BuildContext context, NyihaUser u, Color ax) {
  final resolved = NyihaApi.resolveAvatarUrl(u.avatarUrl);
  if (resolved.isEmpty) {
    return Container(
      color: ax.withOpacity(0.22),
      alignment: Alignment.center,
      child: const Text('👤', style: TextStyle(fontSize: 40)),
    );
  }
  return Image.network(
    resolved,
    width: 86,
    height: 86,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return Container(
        color: ax.withOpacity(0.12),
        alignment: Alignment.center,
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: ax),
        ),
      );
    },
    errorBuilder: (_, __, ___) => Container(
      color: ax.withOpacity(0.15),
      alignment: Alignment.center,
      child: const Text('👤', style: TextStyle(fontSize: 40)),
    ),
  );
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final u = app.user;
    final ax = NyihaColors.accent(context);
    final req = app.ticksRequiredAnnualSetting;
    final paid = u.ticksPaid;
    final owed = req <= 0 ? 0 : (req - paid).clamp(0, req);
    final goldMember = app.isMemberApproved && req > 0 && paid >= req;
    const gold = Color(0xFFE6B422);
    const goldDeep = Color(0xFFB8860B);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
            decoration: NyihaDecorations.homeHeader(context),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        app.toggleTheme();
                        showNyihaToast(context, app.isDark ? 'Usiku' : 'Mchana');
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: ax.withOpacity(0.14),
                        foregroundColor: ax,
                      ),
                      icon: Icon(app.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                    ),
                  ],
                ),
                if (u.adminWarning.trim().isNotEmpty) ...[
                  Material(
                    color: Colors.red.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              u.adminWarning,
                              style: nyihaNunito(context, size: 13, height: 1.35, color: NyihaColors.onSurface(context)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: goldMember
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFE566), gold, goldDeep],
                          )
                        : NyihaColors.primaryButtonGradient(context),
                    border: Border.all(color: goldMember ? gold : ax.withOpacity(0.5), width: goldMember ? 4 : 3),
                    boxShadow: [
                      BoxShadow(
                        color: (goldMember ? gold : ax).withOpacity(goldMember ? 0.5 : 0.3),
                        blurRadius: goldMember ? 22 : 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: ClipOval(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 86,
                          height: 86,
                          child: _profileAvatarInner(context, u, ax),
                        ),
                        if (app.profileAvatarUploading)
                          Container(
                            width: 86,
                            height: 86,
                            color: Colors.black.withOpacity(0.45),
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(u.name, style: nyihaCinzel(context, size: 22)),
                Text('@${u.username}', style: nyihaNunito(context, size: 13, color: NyihaColors.onSurfaceMuted(context))),
                const SizedBox(height: 12),
                _profileBadge(context, app, goldMember, gold, goldDeep),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: KenteStrip(height: 5)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.12,
                children: [
                  _statBox(
                    context,
                    Icons.paid_rounded,
                    '$paid tiki',
                    'Amelipa',
                    onTap: () => openLipaTikiScreen(context),
                  ),
                  _statBox(context, Icons.format_list_numbered_rounded, '$req tiki', 'Jumla (mwaka)'),
                  _statBox(context, Icons.priority_high_rounded, '$owed tiki', 'Anadaiwa'),
                  _statBox(
                    context,
                    Icons.account_balance_wallet_rounded,
                    u.balance > 0 ? 'TZS ${u.balance}' : 'Hakuna',
                    'Deni (TZS)',
                    onTap: u.balance > 0 ? () => openLipaTikiScreen(context) : null,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              if (u.adminProfileNote.trim().isNotEmpty) ...[
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.admin_panel_settings_outlined, color: ax, size: 22),
                          const SizedBox(width: 10),
                          Text('Maelezo kutoka kwa wasimamizi', style: nyihaCinzel(context, size: 15)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        u.adminProfileNote,
                        style: nyihaNunito(context, size: 14, height: 1.4, color: NyihaColors.onSurface(context)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Taarifa za kibinafsi', style: nyihaCinzel(context, size: 16)),
                    const SizedBox(height: 18),
                    _infoRow(context, Icons.phone_android_rounded, 'Simu', u.phone),
                    _infoRow(context, Icons.place_rounded, 'Makazi', u.location),
                    _infoRow(context, Icons.child_care_rounded, 'Watoto', '${u.children}'),
                    _infoRow(context, Icons.favorite_rounded, 'Hali ya ndoa', 'Ameoa'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BtnGold(
                label: 'Hariri profaili',
                icon: Icons.edit_rounded,
                onPressed: () => _pickProfilePhoto(context, app),
              ),
              const SizedBox(height: 12),
              BtnOutline(
                label: 'Duka la Nyiha',
                icon: Icons.storefront_rounded,
                onPressed: () => context.read<AppState>().setMainTab(2),
              ),
              const SizedBox(height: 12),
              BtnOutline(
                label: 'Matangazo & takwimu',
                icon: Icons.campaign_rounded,
                onPressed: () => openMatangazoScreen(context),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Historia ya malipo', style: nyihaCinzel(ctx, size: 20)),
                          const SizedBox(height: 16),
                          _payRow(ctx, 'Juni 2025', 'TZS 2,000', 'Imelipwa'),
                          _payRow(ctx, 'Mei 2025', 'TZS 2,000', 'Imelipwa'),
                          _payRow(ctx, 'Mar 2025', 'TZS 2,000', 'Inadaiwa'),
                        ],
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(color: NyihaColors.accent(context).withOpacity(0.2)),
                  foregroundColor: NyihaColors.onSurface(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Align(alignment: Alignment.centerLeft, child: Text('Historia ya malipo')),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Unataka kutoka?', style: nyihaCinzel(ctx, size: 20)),
                      content: Text('Unaweza kurudi wakati wowote.', style: nyihaNunito(ctx, size: 14)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ghairi')),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.read<AppState>().setScreen(AppScreen.login);
                            showNyihaToast(context, 'Umefanikiwa kutoka.');
                          },
                          child: const Text('Toka'),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(color: Colors.red.withOpacity(0.35)),
                  foregroundColor: Colors.red.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Toka (logout)'),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _profileBadge(BuildContext context, AppState app, bool goldMember, Color gold, Color goldDeep) {
    if (goldMember) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gold.withOpacity(0.22), goldDeep.withOpacity(0.12)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: gold.withOpacity(0.9)),
          boxShadow: [BoxShadow(color: gold.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, size: 22, color: goldDeep),
            const SizedBox(width: 8),
            Text(
              'Mwanachama thabiti — tiki zote zimelipwa',
              style: nyihaNunito(context, size: 12, weight: FontWeight.w800, color: goldDeep),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (app.isMemberApproved) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: NyihaColors.greenAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: NyihaColors.greenAccent.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, size: 16, color: NyihaColors.greenAccent),
            const SizedBox(width: 6),
            Text(
              'Ameidhinishwa',
              style: nyihaNunito(context, size: 12, weight: FontWeight.w700, color: NyihaColors.greenAccent),
            ),
          ],
        ),
      );
    }
    final st = app.user.status.trim().toLowerCase();
    final pending = st == 'pending';
    final chip = pending ? Colors.orange.shade800 : Colors.red.shade700;
    final label = pending ? 'Anasubiri uidhinishaji' : 'Akaunti imesitishwa';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: chip.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: chip.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(pending ? Icons.hourglass_empty_rounded : Icons.block_rounded, size: 16, color: chip),
          const SizedBox(width: 6),
          Text(label, style: nyihaNunito(context, size: 12, weight: FontWeight.w700, color: chip)),
        ],
      ),
    );
  }

  Widget _statBox(BuildContext context, IconData icon, String v, String l, {VoidCallback? onTap}) {
    final card = GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26, color: NyihaColors.accent(context)),
          const SizedBox(height: 10),
          Text(v, style: nyihaCinzel(context, size: 18, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(l, style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context))),
        ],
      ),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: card),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: NyihaColors.accent(context).withOpacity(0.88)),
          const SizedBox(width: 12),
          SizedBox(
            width: 88,
            child: Text(label, style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context))),
          ),
          Expanded(child: Text(value, style: nyihaNunito(context, size: 14, weight: FontWeight.w600, color: NyihaColors.onSurface(context)))),
        ],
      ),
    );
  }

  Widget _payRow(BuildContext context, String m, String a, String s) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(m, style: nyihaNunito(context, size: 14, weight: FontWeight.w600)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(a, style: nyihaCinzel(context, size: 14, color: NyihaColors.accent(context))),
              Text(
                s,
                style: nyihaNunito(
                  context,
                  size: 11,
                  color: s == 'Imelipwa' ? NyihaColors.greenAccent : Colors.redAccent.shade200,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
