import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import '../widgets/admin_community_post_card.dart';
import '../widgets/event_feed_tile.dart';
import '../widgets/glass_card.dart';

/// Hub ya jamii: matukio ya jamii (machapisho) kisha matangazo (kalenda).
void openMatangazoScreen(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => const MatangazoScreen(),
    ),
  );
}

class MatangazoScreen extends StatelessWidget {
  const MatangazoScreen({super.key});

  static int _totalReactions(AppState app) {
    var n = 0;
    for (final p in app.matangazoPosts) {
      for (final c in app.adminPostReactionCounts(p.id).values) {
        n += c;
      }
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tc2 = NyihaColors.onSurfaceMuted(context);
    final ax = NyihaColors.accent(context);
    final adminCount = app.matangazoPosts.length;
    final eventCount = app.jamiiEvents.length;
    final reactionTotal = _totalReactions(app);
    final tagKinds = app.matangazoPosts.map((p) => p.tag).toSet().length;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? NyihaColors.earth900 : NyihaColors.lightSurface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? NyihaColors.earth850 : NyihaColors.lightSurface,
            foregroundColor: NyihaColors.onSurface(context),
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Matangazo', style: nyihaCinzel(context, size: 20)),
                Text(
                  'Matukio ya jamii na matangazo ya kalenda',
                  style: nyihaNunito(context, size: 11, color: tc2),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TAKWIMU', style: nyihaSectionLabel(context)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.35,
                    children: [
                      _StatTile(
                        icon: Icons.groups_rounded,
                        value: '$adminCount',
                        label: 'Matukio ya jamii',
                      ),
                      _StatTile(
                        icon: Icons.campaign_rounded,
                        value: '$eventCount',
                        label: 'Matangazo',
                      ),
                      _StatTile(
                        icon: Icons.favorite_rounded,
                        value: '$reactionTotal',
                        label: 'Reactions jumla',
                      ),
                      _StatTile(
                        icon: Icons.label_rounded,
                        value: '$tagKinds',
                        label: 'Aina za machapisho',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(Icons.groups_rounded, color: ax, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wanajamii waliosajiliwa',
                                style: nyihaNunito(context, size: 12, color: tc2),
                              ),
                              Text(
                                '${app.managedMembers.length}',
                                style: nyihaCinzel(context, size: 22, weight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
            sliver: SliverToBoxAdapter(
              child: Text('MATUKIO YA JAMII', style: nyihaSectionLabel(context)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => AdminCommunityPostCard(post: app.matangazoPosts[i]),
                childCount: app.matangazoPosts.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
            sliver: SliverToBoxAdapter(
              child: Text('MATANGAZO', style: nyihaSectionLabel(context)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => EventFeedTile(event: app.jamiiEvents[i]),
                childCount: app.jamiiEvents.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ax = NyihaColors.accent(context);
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: ax),
          const SizedBox(height: 8),
          Text(value, style: nyihaCinzel(context, size: 22, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            label,
            style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
