import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';

/// Live-style chat with the duka seller (demo: instant thread + simulated replies).
Future<void> showDukaSellerChatSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _DukaSellerChatBody(),
  );
}

class _DukaSellerChatBody extends StatefulWidget {
  const _DukaSellerChatBody();

  @override
  State<_DukaSellerChatBody> createState() => _DukaSellerChatBodyState();
}

class _DukaSellerChatBodyState extends State<_DukaSellerChatBody> {
  final _textCtrl = TextEditingController();
  final _scroll = ScrollController();
  int _lastMsgLen = 0;

  @override
  void dispose() {
    _textCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _send(AppState app) {
    final t = _textCtrl.text.trim();
    if (t.isEmpty) return;
    app.sendSellerMessage(t);
    _textCtrl.clear();
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final msgs = app.messagesSeller;
    if (msgs.length != _lastMsgLen) {
      _lastMsgLen = msgs.length;
      _scrollToEnd();
    }

    final maxH = MediaQuery.of(context).size.height * 0.92;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: isDark ? NyihaColors.earth850 : NyihaColors.lightSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NyihaColors.accent(context).withOpacity(0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: NyihaColors.accent(context).withOpacity(0.15),
                  child: Text('🛍️', style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Muuzaji Duka', style: nyihaCinzel(context, size: 20)),
                      Text(
                        'Mazungumzo ya moja kwa moja',
                        style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: NyihaColors.onSurfaceMuted(context)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: NyihaColors.accent(context).withOpacity(0.12)),
          Expanded(
            child: msgs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 48,
                            color: NyihaColors.onSurfaceMuted(context).withOpacity(0.45),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Bado hakuna ujumbe. Andika hapa — muuzaji ataona mara moja (demo).',
                            textAlign: TextAlign.center,
                            style: nyihaNunito(context, size: 14, color: NyihaColors.onSurfaceMuted(context)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: msgs.length,
                    itemBuilder: (_, i) => _Bubble(msg: msgs[i]),
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    minLines: 1,
                    maxLines: 4,
                    style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
                    decoration: InputDecoration(
                      hintText: 'Andika kwa muuzaji...',
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.06) : NyihaColors.lightSurfaceMuted,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onSubmitted: (_) => _send(app),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: NyihaColors.accent(context),
                    foregroundColor: NyihaColors.onPrimaryButton(context),
                  ),
                  onPressed: () => _send(app),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});

  final ChatMsg msg;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (msg.me) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          decoration: BoxDecoration(
            gradient: NyihaColors.primaryButtonGradient(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(msg.text, style: nyihaNunito(context, size: 13, color: NyihaColors.onPrimaryButton(context))),
              Text(
                msg.time,
                style: nyihaNunito(context, size: 10, color: NyihaColors.onPrimaryButton(context).withOpacity(0.65)),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: NyihaColors.accent(context).withOpacity(0.15),
            child: Text(msg.emoji ?? '👤', style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.from,
                  style: nyihaNunito(context, size: 10, color: NyihaColors.accent(context).withOpacity(0.75)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.08) : NyihaColors.lightSurfaceMuted,
                    border: Border.all(color: NyihaColors.accent(context).withOpacity(0.14)),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(msg.text, style: nyihaNunito(context, size: 13, color: NyihaColors.onSurface(context))),
                      Text(
                        msg.time,
                        style: nyihaNunito(
                          context,
                          size: 10,
                          color: NyihaColors.onSurfaceMuted(context).withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
