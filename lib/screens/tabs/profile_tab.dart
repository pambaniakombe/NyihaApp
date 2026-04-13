import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart' show AppState, AppScreen;
import '../lipa_tiki_screen.dart';
import '../../theme/nyiha_colors.dart';
import '../../theme/nyiha_text.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kente_strip.dart';
import '../../widgets/nyiha_buttons.dart';
import '../../widgets/nyiha_toast.dart';
import '../matangazo_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final u = app.user;
    final ax = NyihaColors.accent(context);
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
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: NyihaColors.primaryButtonGradient(context),
                    border: Border.all(color: ax.withOpacity(0.5), width: 3),
                    boxShadow: [BoxShadow(color: ax.withOpacity(0.3), blurRadius: 28, offset: const Offset(0, 10))],
                  ),
                  alignment: Alignment.center,
                  child: const Text('👨🏾', style: TextStyle(fontSize: 42)),
                ),
                const SizedBox(height: 16),
                Text(u.name, style: nyihaCinzel(context, size: 22)),
                Text('@${u.username}', style: nyihaNunito(context, size: 13, color: NyihaColors.onSurfaceMuted(context))),
                const SizedBox(height: 12),
                Container(
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
                      Text('Ameidhinishwa', style: nyihaNunito(context, size: 12, weight: FontWeight.w700, color: NyihaColors.greenAccent)),
                    ],
                  ),
                ),
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
                    Icons.confirmation_number_rounded,
                    '${app.user.ticksPaid}/${AppState.ticksRequiredAnnual}',
                    'Tiki zilizolipwa',
                    onTap: () => openLipaTikiScreen(context),
                  ),
                  _statBox(context, Icons.account_balance_wallet_rounded, 'TZS 2,000', 'Deni'),
                  _statBox(context, Icons.calendar_today_rounded, '2021', 'Mwaka wa kujiunga'),
                  _statBox(context, Icons.workspace_premium_rounded, 'Mwanachama', 'Daraja'),
                ],
              ),
              const SizedBox(height: 22),
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
                onPressed: () => showNyihaToast(context, 'Kurasa ya kuhariri profaili...'),
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
