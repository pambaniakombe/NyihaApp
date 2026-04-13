import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart' show AppState;
import '../../theme/nyiha_colors.dart';
import '../../theme/nyiha_text.dart';
import '../../screens/lipa_tiki_screen.dart';
import '../../screens/matangazo_screen.dart';
import '../../utils/greeting.dart';
import '../../widgets/admin_community_post_card.dart';
import '../../widgets/event_feed_tile.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nyiha_product_carousel.dart';
import '../../widgets/nyiha_toast.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final u = app.user;
    final first = u.name.split(' ').first;
    final tc = NyihaColors.onSurface(context);
    final tc2 = NyihaColors.onSurfaceMuted(context);
    final ax = NyihaColors.accent(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            decoration: NyihaDecorations.homeHeader(context),
            padding: const EdgeInsets.fromLTRB(22, 52, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            swahiliTimeGreeting(),
                            style: nyihaNunito(context, size: 12, weight: FontWeight.w600, color: ax.withOpacity(0.9)),
                          ),
                          const SizedBox(height: 6),
                          Text('$first', style: nyihaCinzel(context, size: 24)),
                          Text(
                            'Karibu kwenye Nyumbani',
                            style: nyihaNunito(context, size: 13, color: tc2),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            app.toggleTheme();
                            showNyihaToast(context, app.isDark ? 'Hali ya usiku' : 'Hali ya mchana');
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: ax.withOpacity(0.14),
                            foregroundColor: ax,
                          ),
                          icon: Icon(app.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: NyihaColors.primaryButtonGradient(context),
                            border: Border.all(color: ax.withOpacity(0.55)),
                            boxShadow: [
                              BoxShadow(color: ax.withOpacity(0.32), blurRadius: 20, offset: const Offset(0, 6)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text('👨🏾', style: TextStyle(fontSize: 22)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                NyihaProductCarousel(
                  onSlideTap: (_) => app.setMainTab(2),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  _quick(context, Icons.payment_rounded, 'Lipa tiki', () => openLipaTikiScreen(context)),
                  const SizedBox(width: 10),
                  _quick(context, Icons.campaign_rounded, 'Matangazo', () => openMatangazoScreen(context)),
                  const SizedBox(width: 10),
                  _quick(context, Icons.groups_rounded, 'Wanachama', () {
                    app.setMainTab(1);
                    app.setCommunitySection(2);
                  }),
                  const SizedBox(width: 10),
                  _quick(context, Icons.storefront_rounded, 'Duka', () => app.setMainTab(2)),
                ],
              ),
              const SizedBox(height: 26),
              Builder(
                builder: (context) {
                  final req = AppState.ticksRequiredAnnual;
                  final paid = app.user.ticksPaid;
                  final owed = app.ticksOwedAnnual;
                  final pct = req == 0 ? 0.0 : paid / req;
                  return InkWell(
                    onTap: () => openLipaTikiScreen(context),
                    borderRadius: BorderRadius.circular(18),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mkeka wa mwezi', style: nyihaNunito(context, size: 15, weight: FontWeight.w700, color: tc)),
                                  Text('$paid / $req tiki', style: nyihaNunito(context, size: 12, color: tc2)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: NyihaColors.primaryButtonGradient(context),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(color: ax.withOpacity(0.22), blurRadius: 12, offset: const Offset(0, 4)),
                                  ],
                                ),
                                child: Text(
                                  '${(pct * 100).round()}%',
                                  style: nyihaNunito(context, size: 11, weight: FontWeight.w800, color: NyihaColors.onPrimaryButton(context)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: pct.clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: ax.withOpacity(0.15),
                              color: ax,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            owed > 0 ? 'Bado tiki $owed hadi ukamilishe mwaka' : 'Umekamilisha malipo ya tiki za mwaka 🎉',
                            style: nyihaNunito(context, size: 12, color: ax.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: Text('MATUKIO YA JAMII', style: nyihaSectionLabel(context))),
                  TextButton(
                    onPressed: () => openMatangazoScreen(context),
                    child: Text(
                      'Angalia yote',
                      style: nyihaNunito(context, size: 12, weight: FontWeight.w700, color: ax),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...app.matangazoPosts.map((p) => AdminCommunityPostCard(post: p)),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: Text('MATANGAZO', style: nyihaSectionLabel(context))),
                  TextButton(
                    onPressed: () => openMatangazoScreen(context),
                    child: Text(
                      'Angalia yote',
                      style: nyihaNunito(context, size: 12, weight: FontWeight.w700, color: ax),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...app.jamiiEvents.take(3).map((e) => EventFeedTile(event: e)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _quick(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final ax = NyihaColors.accent(context);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
            decoration: BoxDecoration(
              color: ax.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ax.withOpacity(0.16)),
            ),
            child: Column(
              children: [
                Icon(icon, size: 24, color: ax),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: nyihaNunito(context, size: 10, weight: FontWeight.w700, color: NyihaColors.onSurface(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
