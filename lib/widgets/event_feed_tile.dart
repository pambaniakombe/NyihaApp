import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import 'glass_card.dart';

/// Calendar-style event row (home feed, Matangazo screen).
class EventFeedTile extends StatelessWidget {
  const EventFeedTile({super.key, required this.event});

  final MockEvent event;

  @override
  Widget build(BuildContext context) {
    final ax = NyihaColors.accent(context);
    final tc = NyihaColors.onSurface(context);
    final tc2 = NyihaColors.onSurfaceMuted(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [ax.withOpacity(0.22), ax.withOpacity(0.08)],
                ),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.event_rounded, color: ax.withOpacity(0.95)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: nyihaNunito(context, size: 14, weight: FontWeight.w700, color: tc)),
                  const SizedBox(height: 4),
                  Text(event.date, style: nyihaNunito(context, size: 12, color: tc2)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ax.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(event.tag, style: nyihaNunito(context, size: 10, weight: FontWeight.w800, color: ax)),
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
