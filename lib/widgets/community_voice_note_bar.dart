import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';

/// Play/stop for a local voice file (Mazungumzo bubbles).
class CommunityVoiceNoteBar extends StatefulWidget {
  const CommunityVoiceNoteBar({
    super.key,
    required this.filePath,
    required this.durationSec,
    required this.isMe,
  });

  final String filePath;
  final int durationSec;
  final bool isMe;

  @override
  State<CommunityVoiceNoteBar> createState() => _CommunityVoiceNoteBarState();
}

class _CommunityVoiceNoteBarState extends State<CommunityVoiceNoteBar> {
  final _player = AudioPlayer();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (kIsWeb) return;
    try {
      if (_playing) {
        await _player.pause();
        if (mounted) setState(() => _playing = false);
      } else {
        await _player.play(DeviceFileSource(widget.filePath));
        if (mounted) setState(() => _playing = true);
      }
    } catch (_) {
      if (mounted) setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ax = NyihaColors.accent(context);
    final onBtn = widget.isMe ? NyihaColors.onPrimaryButton(context) : ax;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: kIsWeb ? null : _toggle,
          icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: onBtn),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ujumbe wa sauti', style: nyihaNunito(context, size: 12, weight: FontWeight.w600, color: onBtn)),
            Text(
              '${widget.durationSec}s',
              style: nyihaNunito(context, size: 10, color: onBtn.withOpacity(0.75)),
            ),
          ],
        ),
      ],
    );
  }
}
