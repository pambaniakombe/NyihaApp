import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import 'nyiha_toast.dart';

/// Text + gallery image + voice note for Mazungumzo ya Jamii.
class CommunityChatComposer extends StatefulWidget {
  const CommunityChatComposer({super.key, required this.canPost});

  /// When `false`, composer is read-only (Jamii chat locked by admins).
  final bool canPost;

  @override
  State<CommunityChatComposer> createState() => _CommunityChatComposerState();
}

class _CommunityChatComposerState extends State<CommunityChatComposer> {
  final _ctrl = TextEditingController();
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();
  bool _recording = false;
  DateTime? _recordStart;

  @override
  void dispose() {
    _ctrl.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (!widget.canPost) {
      showNyihaToast(context, 'Mazungumzo yamesitishwa na wasimamizi.');
      return;
    }
    try {
      final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 82);
      if (x == null || !mounted) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 6 * 1024 * 1024) {
        showNyihaToast(context, 'Picha ni kubwa sana. Chagua nyingine.');
        return;
      }
      final cap = _ctrl.text.trim();
      final app = context.read<AppState>();
      final ok = await app.sendCommunityImage(bytes, caption: cap);
      if (!mounted) return;
      if (ok) {
        _ctrl.clear();
      } else {
        showNyihaToast(context, app.lastApiError ?? 'Haikuwezekana kutuma picha.');
      }
    } catch (_) {
      if (mounted) showNyihaToast(context, 'Haikuwezekana kuchagua picha.');
    }
  }

  Future<void> _toggleRecord() async {
    if (!widget.canPost) {
      showNyihaToast(context, 'Mazungumzo yamesitishwa na wasimamizi.');
      return;
    }
    if (kIsWeb) {
      showNyihaToast(context, 'Rekodi ya sauti inapatikana kwenye simu (Android/iOS), si kwenye wavuti.');
      return;
    }
    try {
      if (_recording) {
        final path = await _recorder.stop();
        _recording = false;
        final start = _recordStart;
        _recordStart = null;
        if (mounted) setState(() {});
        var sec = 0;
        if (start != null) sec = DateTime.now().difference(start).inSeconds;
        if (path != null && sec >= 1 && mounted) {
          final app = context.read<AppState>();
          final ok = await app.sendCommunityVoice(filePath: path, durationSec: sec.clamp(1, 3600));
          if (!mounted) return;
          if (!ok) showNyihaToast(context, app.lastApiError ?? 'Haikuwezekana kutuma sauti.');
        } else if (mounted && path != null && sec < 1) {
          showNyihaToast(context, 'Rekodi ni fupi mno.');
        }
        return;
      }
      final ok = await _recorder.hasPermission();
      if (ok != true) {
        if (mounted) showNyihaToast(context, 'Ruhusa ya maikrofono inahitajika.');
        return;
      }
      final dir = await getTemporaryDirectory();
      final filePath = p.join(dir.path, 'nyiha_comm_${DateTime.now().millisecondsSinceEpoch}.m4a');
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: filePath);
      _recording = true;
      _recordStart = DateTime.now();
      if (mounted) setState(() {});
    } catch (_) {
      _recording = false;
      _recordStart = null;
      if (mounted) {
        setState(() {});
        showNyihaToast(context, 'Rekodi haikuwezekana kwenye kifaa hiki.');
      }
    }
  }

  Future<void> _sendText() async {
    if (!widget.canPost) {
      showNyihaToast(context, 'Mazungumzo yamesitishwa na wasimamizi.');
      return;
    }
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    final app = context.read<AppState>();
    final ok = await app.sendCommunityMessage(t);
    if (!mounted) return;
    if (ok) {
      _ctrl.clear();
      setState(() {});
    } else {
      showNyihaToast(context, app.lastApiError ?? 'Haikuwezekana kutuma ujumbe.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ax = NyihaColors.accent(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.canPost)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.amber.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 18, color: Colors.amber.shade800),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Wasimamizi wamesitisha ujumbe wa wanajamii. Unaweza kusoma tu — ni wasimamizi pekee wanaweza kutuma.',
                          style: nyihaNunito(context, size: 12, height: 1.35, color: NyihaColors.onSurface(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_recording)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Inarekodi... gusa sauti tena kuisha na kutuma',
                      style: nyihaNunito(context, size: 12, color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Material(
                color: ax.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                child: IconButton(
                  onPressed: widget.canPost ? _pickImage : null,
                  icon: Icon(Icons.image_outlined, color: widget.canPost ? ax : ax.withOpacity(0.35)),
                  tooltip: 'Chagua picha',
                ),
              ),
              const SizedBox(width: 6),
              Material(
                color: _recording ? Colors.redAccent.withOpacity(0.15) : ax.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                child: IconButton(
                  onPressed: widget.canPost ? _toggleRecord : null,
                  icon: Icon(
                    _recording ? Icons.stop_rounded : Icons.mic_none_rounded,
                    color: _recording ? Colors.redAccent : (widget.canPost ? ax : ax.withOpacity(0.35)),
                  ),
                  tooltip: _recording ? 'Acha rekodi' : 'Rekodi sauti',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  minLines: 1,
                  maxLines: 5,
                  readOnly: !widget.canPost,
                  enabled: widget.canPost,
                  style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
                  decoration: InputDecoration(
                    hintText: widget.canPost ? 'Andika ujumbe...' : 'Mazungumzo yamesitishwa…',
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.06) : NyihaColors.lightSurfaceMuted,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  onSubmitted: (_) => _sendText(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: widget.canPost ? ax : ax.withOpacity(0.4),
                  foregroundColor: NyihaColors.onPrimaryButton(context),
                ),
                onPressed: widget.canPost ? _sendText : null,
                icon: const Icon(Icons.send_rounded),
                tooltip: 'Tuma',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
