import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import '../../theme/nyiha_colors.dart';
import '../../theme/nyiha_text.dart';
import '../../widgets/community_chat_composer.dart';
import '../../widgets/community_voice_note_bar.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kente_strip.dart';
import '../../widgets/nyiha_toast.dart';
import '../matangazo_screen.dart';
import '../private_chat_screen.dart';

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  final _memberSearch = TextEditingController();

  @override
  void dispose() {
    _memberSearch.dispose();
    super.dispose();
  }

  static const _allJamiiSections = [
    ('Mazungumzo', Icons.chat_bubble_outline, 0),
    ('Admin', Icons.bolt_outlined, 1),
    ('Wanachama', Icons.people_outline, 2),
    ('Matukio', Icons.event_outlined, 3),
    ('Mkeka', Icons.bar_chart_outlined, 4),
    ('Kura', Icons.how_to_vote_outlined, 5),
  ];

  List<(String, IconData, int)> _visibleJamiiSections(AppState app) {
    final allowed = app.enabledJamiiSectionIndices.toSet();
    return [for (final s in _allJamiiSections) if (allowed.contains(s.$3)) s];
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (!app.enabledJamiiSectionIndices.contains(app.communitySection)) {
      Future.microtask(() {
        if (context.mounted) app.ensureCommunitySectionValid();
      });
    }
    final sections = _visibleJamiiSections(app);
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: NyihaDecorations.communityHeader(context),
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jamii ya Nyiha', style: nyihaCinzel(context, size: 22)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: sections.map((s) {
                    final sel = app.communitySection == s.$3;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () => app.setCommunitySection(s.$3),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            color: sel ? NyihaColors.accent(context).withOpacity(0.16) : NyihaColors.accent(context).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: NyihaColors.accent(context).withOpacity(sel ? 0.42 : 0.16)),
                            boxShadow: sel
                                ? [
                                    BoxShadow(
                                      color: NyihaColors.accent(context).withOpacity(0.12),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            children: [
                              Icon(s.$2, size: 20, color: NyihaColors.accent(context)),
                              const SizedBox(height: 4),
                              Text(
                                s.$1,
                                style: nyihaNunito(context, size: 9, weight: FontWeight.w800, color: NyihaColors.accent(context)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const KenteStrip(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              key: ValueKey(app.communitySection),
              child: _body(context, app),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, AppState app) {
    switch (app.communitySection) {
      case 0:
      case 1:
        return _chatView(context, app);
      case 2:
        return _membersView(context);
      case 3:
        return _eventsView(context);
      case 4:
        return _mkekaView(context, app);
      case 5:
        return _pollsView(context, app);
      default:
        return _chatView(context, app);
    }
  }

  Widget _chatView(BuildContext context, AppState app) {
    final admin = app.communitySection == 1;
    final msgs = admin ? app.messagesAdmin : app.messagesCommunity;
    return Column(
      key: ValueKey(admin ? 'a' : 'c'),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              admin ? 'Mazungumzo na Admin' : 'Mazungumzo ya Jamii',
              style: nyihaCinzel(context, size: 16),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: msgs.length,
            itemBuilder: (_, i) {
              final m = msgs[i];
              return _bubble(context, m);
            },
          ),
        ),
        if (admin)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Mazungumzo ya Admin — Soma tu',
              textAlign: TextAlign.center,
              style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context)),
            ),
          )
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (app.canCurrentUserPostCommunityChat && !app.jamiiCommunityChatMembersCanSend)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Unatumia ruhusa ya kituo cha wasimamizi — unaweza kutuma ujumbe.',
                    textAlign: TextAlign.center,
                    style: nyihaNunito(context, size: 11, color: NyihaColors.accent(context)),
                  ),
                ),
              CommunityChatComposer(canPost: app.canCurrentUserPostCommunityChat),
            ],
          ),
      ],
    );
  }

  Widget _bubbleMe(BuildContext context, ChatMsg m) {
    final maxW = MediaQuery.of(context).size.width * 0.75;
    final on = NyihaColors.onPrimaryButton(context);
    final radius = const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(4),
    );

    if (m.mediaKind == ChatMediaKind.image && m.imageBytes != null) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(maxWidth: maxW),
          decoration: BoxDecoration(
            gradient: NyihaColors.primaryButtonGradient(context),
            borderRadius: radius,
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  m.imageBytes!,
                  width: 220,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 220,
                    height: 120,
                    color: on.withOpacity(0.2),
                    alignment: Alignment.center,
                    child: Icon(Icons.broken_image_outlined, color: on),
                  ),
                ),
              ),
              if (m.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(m.text, style: nyihaNunito(context, size: 13, color: on)),
                ),
              ],
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(m.time, style: nyihaNunito(context, size: 10, color: on.withOpacity(0.65))),
              ),
            ],
          ),
        ),
      );
    }

    if (m.mediaKind == ChatMediaKind.voice &&
        m.voiceFilePath != null &&
        m.voiceDurationSec != null) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(maxWidth: maxW),
          decoration: BoxDecoration(
            gradient: NyihaColors.primaryButtonGradient(context),
            borderRadius: radius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CommunityVoiceNoteBar(
                filePath: m.voiceFilePath!,
                durationSec: m.voiceDurationSec!,
                isMe: true,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(m.time, style: nyihaNunito(context, size: 10, color: on.withOpacity(0.65))),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: maxW),
        decoration: BoxDecoration(
          gradient: NyihaColors.primaryButtonGradient(context),
          borderRadius: radius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(m.text, style: nyihaNunito(context, size: 13, color: on)),
            Text(m.time, style: nyihaNunito(context, size: 10, color: on.withOpacity(0.65))),
          ],
        ),
      ),
    );
  }

  Widget _bubble(BuildContext context, ChatMsg m) {
    if (m.me) {
      return _bubbleMe(context, m);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: NyihaColors.accent(context).withOpacity(0.15),
            child: Text(m.emoji ?? '👤', style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.from, style: nyihaNunito(context, size: 10, color: NyihaColors.accent(context).withOpacity(0.6))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.08)
                        : NyihaColors.lightSurfaceMuted,
                    border: Border.all(
                      color: NyihaColors.accent(context).withOpacity(0.12),
                    ),
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
                      Text(m.text, style: nyihaNunito(context, size: 13)),
                      Text(
                        m.time,
                        style: nyihaNunito(context, size: 10, color: NyihaColors.onSurfaceMuted(context).withOpacity(0.85)),
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

  Widget _membersView(BuildContext context) {
    var list = mockMembers.toList();
    final q = _memberSearch.text.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((m) => m.name.toLowerCase().contains(q) || m.loc.toLowerCase().contains(q)).toList();
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _memberSearch,
          onChanged: (_) => setState(() {}),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search_rounded, color: NyihaColors.accent(context)),
            hintText: 'Tafuta mwanachama...',
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gusa mtu kuwasiliana naye faragha (DM).',
          style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context)),
        ),
        const SizedBox(height: 16),
        ...list.map((m) => _memberTile(context, m)),
      ],
    );
  }

  Widget _memberTile(BuildContext context, MockMember m) {
    final app = context.read<AppState>();
    final isSelf = m.name == app.user.name;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          if (isSelf) {
            showNyihaToast(context, 'Huwezi kutuma ujumbe wa faragha kwa mwenyewe');
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PrivateChatScreen(member: m),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: GlassCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(m.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(m.name, style: nyihaNunito(context, size: 13, weight: FontWeight.w700)),
                        ),
                        if (!isSelf)
                          Icon(Icons.chat_bubble_outline_rounded, size: 16, color: NyihaColors.accent(context).withOpacity(0.7)),
                      ],
                    ),
                    Text(
                      isSelf ? '📍 ${m.loc} · Wewe' : '📍 ${m.loc}',
                      style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(gradient: NyihaColors.primaryButtonGradient(context), borderRadius: BorderRadius.circular(20)),
                child: Text('${m.ticks} tiki', style: nyihaNunito(context, size: 10, weight: FontWeight.w800, color: NyihaColors.onPrimaryButton(context))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventsView(BuildContext context) {
    final app = context.watch<AppState>();
    final events = app.jamiiEvents;
    final tcMuted = NyihaColors.onSurfaceMuted(context);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => openMatangazoScreen(context),
                borderRadius: BorderRadius.circular(16),
                child: GlassCard(
                  child: Row(
                    children: [
                      Icon(Icons.campaign_rounded, color: NyihaColors.accent(context), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Matangazo & takwimu', style: nyihaNunito(context, size: 14, weight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                              'Taarifa za wakuu, reactions, na kalenda kamili',
                              style: nyihaNunito(context, size: 11, color: tcMuted),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: tcMuted),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final e = events[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: NyihaColors.accent(context)),
                          ),
                          if (i < events.length - 1)
                            Container(
                              width: 2,
                              height: 48,
                              margin: const EdgeInsets.only(top: 4),
                              color: NyihaColors.accent(context).withOpacity(0.15),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(e.title, style: nyihaNunito(context, size: 13, weight: FontWeight.w700))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: NyihaColors.accent(context).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(e.tag, style: nyihaNunito(context, size: 10, weight: FontWeight.w700, color: NyihaColors.accent(context))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(e.desc, style: nyihaNunito(context, size: 12, height: 1.6, color: tcMuted)),
                              const SizedBox(height: 8),
                              Text('📅 ${e.date}', style: nyihaNunito(context, size: 11, color: NyihaColors.accent(context).withOpacity(0.6))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: events.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mkekaView(BuildContext context, AppState app) {
    final sorted = [...mockMembers]..sort((a, b) => b.ticks.compareTo(a.ticks));
    final max = sorted.first.ticks;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Jedwali la Mkeka', style: nyihaCinzel(context, size: 16)),
        const SizedBox(height: 16),
        GlassCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(3, (i) {
              final m = sorted[i];
              return Column(
                children: [
                  Text(['🥇', '🥈', '🥉'][i], style: TextStyle(fontSize: i == 0 ? 32 : 24)),
                  Text(m.name.split(' ').first, style: nyihaNunito(context, size: 11, weight: FontWeight.w700)),
                  Text('${m.ticks}', style: nyihaCinzel(context, size: 13, weight: FontWeight.w800)),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        ...sorted.asMap().entries.map((e) {
          final i = e.key;
          final m = e.value;
          final mine = m.name == app.user.name;
          final pct = (m.ticks / max * 100).round();
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('#${i + 1}', style: nyihaNunito(context, size: 12, color: NyihaColors.cream.withOpacity(0.4))),
                      const SizedBox(width: 8),
                      Text(m.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${m.name}${mine ? ' (Wewe)' : ''}',
                          style: nyihaNunito(context, size: 13, weight: FontWeight.w700, color: mine ? NyihaColors.accent(context) : NyihaColors.cream),
                        ),
                      ),
                      Text('${m.ticks}', style: nyihaCinzel(context, size: 14, weight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 8,
                      backgroundColor: NyihaColors.accent(context).withOpacity(0.15),
                      color: NyihaColors.accent(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _pollsView(BuildContext context, AppState app) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: app.polls.length,
      itemBuilder: (_, pi) {
        final p = app.polls[pi];
        final total = p.options.fold<int>(0, (a, o) => a + o.v);
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.q, style: nyihaNunito(context, size: 14, weight: FontWeight.w700)),
                const SizedBox(height: 16),
                ...p.options.asMap().entries.map((e) {
                  final oi = e.key;
                  final o = e.value;
                  final pct = total == 0 ? 0 : (o.v / total * 100).round();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        app.votePoll(pi, oi);
                        showNyihaToast(context, 'Kura yako imesajiliwa!');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                o.t,
                                style: nyihaNunito(
                                  context,
                                  size: 13,
                                  weight: p.voted && p.votedIdx == oi ? FontWeight.w700 : FontWeight.w400,
                                  color: p.voted && p.votedIdx == oi ? NyihaColors.accent(context) : NyihaColors.cream.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                p.voted ? '$pct%' : '${o.v} kura',
                                style: nyihaNunito(context, size: 12, color: NyihaColors.cream.withOpacity(0.5)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: p.voted ? pct / 100 : 0,
                              minHeight: 8,
                              backgroundColor: NyihaColors.accent(context).withOpacity(0.15),
                              color: NyihaColors.accent(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                if (!p.voted)
                  Text('Bonyeza chaguo lako kupiga kura', style: nyihaNunito(context, size: 11, color: NyihaColors.accent(context).withOpacity(0.5)))
                else
                  Text('Umepiga kura', style: nyihaNunito(context, size: 11, color: Colors.greenAccent.withOpacity(0.8))),
              ],
            ),
          ),
        );
      },
    );
  }
}
