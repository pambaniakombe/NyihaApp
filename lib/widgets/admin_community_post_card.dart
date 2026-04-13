import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import 'glass_card.dart';

/// Home feed card: admin matangazo with image(s) + Telegram-style reactions.
class AdminCommunityPostCard extends StatelessWidget {
  const AdminCommunityPostCard({super.key, required this.post});

  final AdminCommunityPost post;

  @override
  Widget build(BuildContext context) {
    final displayUrls =
        post.imageUrls.isNotEmpty ? post.imageUrls : [kDefaultAdminCommunityPostImage];
    final app = context.watch<AppState>();
    final counts = app.adminPostReactionCounts(post.id);
    final mine = app.myAdminPostReaction(post.id);
    final ax = NyihaColors.accent(context);
    final tc = NyihaColors.onSurface(context);
    final tc2 = NyihaColors.onSurfaceMuted(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: ax.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ax.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 16, color: ax),
                        const SizedBox(width: 6),
                        Text(
                          post.authorLabel,
                          style: nyihaNunito(context, size: 11, weight: FontWeight.w800, color: ax),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ax.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      post.tag,
                      style: nyihaNunito(context, size: 10, weight: FontWeight.w700, color: tc2),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.headline, style: nyihaCinzel(context, size: 18)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: tc2),
                      const SizedBox(width: 6),
                      Text(post.dateLabel, style: nyihaNunito(context, size: 13, color: tc2)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    post.body,
                    style: nyihaNunito(context, size: 14, height: 1.55, color: tc),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: displayUrls.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        displayUrls[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: ax.withOpacity(0.08),
                          alignment: Alignment.center,
                          child: Icon(Icons.broken_image_outlined, color: tc2, size: 40),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: isDark ? Colors.white.withOpacity(0.04) : NyihaColors.lightSurfaceMuted,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ax,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            if (displayUrls.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Telezesha picha',
                    style: nyihaNunito(context, size: 11, color: tc2.withOpacity(0.85)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final kind in kCommunityReactionKinds)
                    _ReactionChip(
                      emoji: kind.emoji,
                      count: counts[kind.key] ?? 0,
                      selected: mine == kind.key,
                      onTap: () => context.read<AppState>().toggleAdminPostReaction(post.id, kind.key),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({
    required this.emoji,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ax = NyihaColors.accent(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? ax.withOpacity(isDark ? 0.22 : 0.14)
                : (isDark ? Colors.white.withOpacity(0.06) : NyihaColors.lightSurfaceMuted),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? ax.withOpacity(0.55) : ax.withOpacity(0.12),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: nyihaNunito(
                    context,
                    size: 12,
                    weight: FontWeight.w700,
                    color: selected ? ax : NyihaColors.onSurfaceMuted(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
