import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../widgets/chat_avatar.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';

/// One-on-one chat with a member (Wanachama → faragha).
class PrivateChatScreen extends StatefulWidget {
  const PrivateChatScreen({super.key, required this.member});

  final MockMember member;

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  int _lastLen = 0;

  @override
  void dispose() {
    _ctrl.dispose();
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
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    app.sendPrivateMessage(
      memberName: widget.member.name,
      memberEmoji: widget.member.emoji,
      text: t,
    );
    _ctrl.clear();
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final msgs = app.privateMessagesFor(widget.member.name);
    if (msgs.length != _lastLen) {
      _lastLen = msgs.length;
      _scrollToEnd();
    }

    final m = widget.member;
    final ax = NyihaColors.accent(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NyihaColors.earth900 : NyihaColors.lightSurface,
      appBar: AppBar(
        backgroundColor: isDark ? NyihaColors.earth850 : NyihaColors.lightSurface,
        foregroundColor: NyihaColors.onSurface(context),
        elevation: 0,
        title: Row(
          children: [
            Text(m.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(m.name, style: nyihaCinzel(context, size: 16)),
                  Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 12, color: ax.withOpacity(0.85)),
                      const SizedBox(width: 4),
                      Text(
                        'Faragha · ${m.loc}',
                        style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: msgs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.forum_outlined, size: 48, color: NyihaColors.onSurfaceMuted(context).withOpacity(0.45)),
                          const SizedBox(height: 12),
                          Text(
                            'Anza mazungumzo na ${m.name.split(' ').first}',
                            textAlign: TextAlign.center,
                            style: nyihaNunito(context, size: 14, color: NyihaColors.onSurfaceMuted(context)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: msgs.length,
                    itemBuilder: (_, i) => _DmBubble(msg: msgs[i]),
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 4,
                    style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
                    decoration: InputDecoration(
                      hintText: 'Andika ujumbe wa faragha...',
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
                    backgroundColor: ax,
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

class _DmBubble extends StatelessWidget {
  const _DmBubble({required this.msg});

  final ChatMsg msg;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myAv = context.watch<AppState>().user.avatarUrl;
    if (msg.me) {
      final mePhoto = msg.avatarUrl?.trim();
      final avUrl = (mePhoto != null && mePhoto.isNotEmpty) ? mePhoto : myAv;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
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
              ),
            ),
            const SizedBox(width: 8),
            ChatAvatar(imageUrl: avUrl, fallbackEmoji: '👤', radius: 16),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ChatAvatar(
            imageUrl: msg.avatarUrl,
            fallbackEmoji: msg.emoji ?? '👤',
            radius: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.from,
                  style: nyihaNunito(
                    context,
                    size: 11,
                    weight: FontWeight.w700,
                    letterSpacing: 0.15,
                    color: NyihaColors.accent(context).withOpacity(0.85),
                  ),
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
