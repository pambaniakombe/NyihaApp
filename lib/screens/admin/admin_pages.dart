import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_models.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import '../../theme/nyiha_colors.dart';
import '../../theme/nyiha_text.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nyiha_toast.dart';
import 'admin_pending_signups_page.dart';

String _jamiiChatPreviewLine(ChatMsg m) {
  switch (m.mediaKind) {
    case ChatMediaKind.image:
      return m.text.isEmpty ? '[Picha]' : m.text;
    case ChatMediaKind.voice:
      return '[Sauti]';
    case ChatMediaKind.text:
      return m.text;
  }
}

/// Overview: metrics, pulse of the community app.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final ax = NyihaColors.accent(context);
    final pendingOrders = app.shopOrders.where((o) => !o.status.contains('malipo yamekamilika')).length;
    final role = app.adminSession?.role == AdminRole.main ? 'Mkuu' : 'Msaidizi';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Habari, ${app.adminSession?.displayName ?? "Admin"}',
                        style: nyihaCinzel(context, size: 20),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ax.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: ax.withOpacity(0.35)),
                      ),
                      child: Text(
                        role,
                        style: nyihaNunito(context, size: 11, weight: FontWeight.w800, color: ax),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Dhibiti malipo, bidhaa, na timu — Settings: Mpangilio na Admin Posts (matukio, machapisho).',
                  style: nyihaNunito(context, size: 13, color: NyihaColors.onSurfaceMuted(context)),
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (ctx) => const AdminPendingSignupsPage(),
                        ),
                      );
                    },
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_add_alt_1_rounded, color: ax, size: 26),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Watumiaji wapya',
                                  style: nyihaCinzel(context, size: 16),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: app.pendingSignupRequests.isNotEmpty
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${app.pendingSignupRequests.length}',
                                  style: nyihaNunito(context, size: 16, weight: FontWeight.w800, color: ax),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right_rounded, color: ax.withOpacity(0.7)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Maombi ya uanachama baada ya malipo — gusa kuona maelezo, kisha idhinisha baada ya '
                            'kuhakikisha ada imepokelewa.',
                            style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Malipo ya tiki na oda za duka: tumia "Mikeka" na "Jumuiya".',
                            style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            delegate: SliverChildListDelegate([
              _StatCard(
                icon: Icons.groups_rounded,
                label: 'Wanajamii',
                value: '${app.managedMembers.length}',
                subtitle: 'kwenye orodha',
                color: ax,
              ),
              _StatCard(
                icon: Icons.shopping_bag_outlined,
                label: 'Oda za Duka',
                value: '${app.shopOrders.length}',
                subtitle: '$pendingOrders zinazofuatiliwa',
                color: const Color(0xFF00BFA5),
              ),
              _StatCard(
                icon: Icons.payments_outlined,
                label: 'Malipo ya tiki',
                value: app.pendingTickPayment == null ? '0' : '1',
                subtitle: app.pendingTickPayment == null ? 'hakuna inayosubiri' : 'inasubiri uidhinishaji',
                color: const Color(0xFFFF9100),
              ),
              _StatCard(
                icon: Icons.campaign_outlined,
                label: 'Ujumbe wa Admin',
                value: '${app.messagesAdmin.length}',
                subtitle: 'kwenye mazungumzo',
                color: const Color(0xFFE040FB),
              ),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text('Shughuli za hivi karibuni', style: nyihaCinzel(context, size: 15)),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final m = app.messagesAdmin[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.emoji ?? '💬', style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.from, style: nyihaNunito(context, size: 12, weight: FontWeight.w700, color: ax)),
                            const SizedBox(height: 4),
                            Text(m.text, maxLines: 3, overflow: TextOverflow.ellipsis, style: nyihaNunito(context, size: 13)),
                            Text(m.time, style: nyihaNunito(context, size: 10, color: NyihaColors.onSurfaceMuted(context))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: math.min(8, app.messagesAdmin.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const Spacer(),
          Text(value, style: nyihaCinzel(context, size: 26)),
          const SizedBox(height: 4),
          Text(label, style: nyihaNunito(context, size: 12, weight: FontWeight.w700)),
          Text(subtitle, style: nyihaNunito(context, size: 10, color: NyihaColors.onSurfaceMuted(context))),
        ],
      ),
    );
  }
}

/// Approve / suspend members, view ticks.
class AdminMembersPage extends StatelessWidget {
  const AdminMembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: app.managedMembers.length,
      itemBuilder: (context, i) {
        final m = app.managedMembers[i];
        final chip = Color(switch (m.status) {
          MemberStatus.approved => 0xFF2D8A4E,
          MemberStatus.pending => 0xFFC45E1A,
          MemberStatus.suspended => 0xFFB00020,
        });
        final statusSw = switch (m.status) {
          MemberStatus.approved => 'Ameidhinishwa',
          MemberStatus.pending => 'Anasubiri',
          MemberStatus.suspended => 'Amesitishwa',
        };
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: NyihaColors.accent(context).withOpacity(0.15),
                  child: Text(m.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: nyihaNunito(context, size: 13, weight: FontWeight.w700)),
                      Text('${m.location} · ${m.phone}', style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context))),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: chip.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusSw,
                              style: nyihaNunito(context, size: 10, weight: FontWeight.w800, color: chip),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('Tiki: ${m.ticks}', style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context))),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: NyihaColors.accent(context)),
                  onSelected: (v) {
                    if (v == 'approve') app.setMemberStatus(m.name, MemberStatus.approved);
                    if (v == 'pending') app.setMemberStatus(m.name, MemberStatus.pending);
                    if (v == 'suspend') app.setMemberStatus(m.name, MemberStatus.suspended);
                    showNyihaToast(context, 'Hali ya ${m.name} imesasishwa.');
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'approve', child: Text('Idhinisha')),
                    const PopupMenuItem(value: 'pending', child: Text('Weka kwenye foleni')),
                    const PopupMenuItem(value: 'suspend', child: Text('Sitisha')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Mazungumzo ya Jamii (dhibiti + hakiki) na orodha ya wanajamii.
class AdminJumuiyaPage extends StatelessWidget {
  const AdminJumuiyaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ax = NyihaColors.accent(context);
    final muted = NyihaColors.onSurfaceMuted(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: TabBar(
              labelColor: ax,
              unselectedLabelColor: muted,
              indicatorColor: ax,
              labelStyle: nyihaNunito(context, size: 13, weight: FontWeight.w700),
              unselectedLabelStyle: nyihaNunito(context, size: 13),
              tabs: const [
                Tab(text: 'Chats'),
                Tab(text: 'Wanajamii'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                AdminJamiiChatsPage(),
                AdminMembersPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dhibiti mazungumzo ya Jamii na uone ujumbe wa hivi karibuni.
class AdminJamiiChatsPage extends StatelessWidget {
  const AdminJamiiChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final ax = NyihaColors.accent(context);
    final muted = NyihaColors.onSurfaceMuted(context);
    final n = app.messagesCommunity.length;
    final preview = n <= 20 ? app.messagesCommunity : app.messagesCommunity.sublist(n - 20);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text('Mazungumzo ya Jamii', style: nyihaCinzel(context, size: 15)),
        const SizedBox(height: 8),
        Text(
          'Wanachama wote wanaona mazungumzo haya kwenye programu ya wanajamii (kichupo Jamii → Mazungumzo).',
          style: nyihaNunito(context, size: 12, color: muted),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: SwitchListTile(
            title: Text('Wanajamii wanaweza kutuma ujumbe', style: nyihaNunito(context, weight: FontWeight.w700)),
            subtitle: Text(
              app.jamiiCommunityChatMembersCanSend
                  ? 'Kila mwanachama anaweza kuandika, picha, na sauti.'
                  : 'Imefungwa: ni wasimamizi pekee (nambari zilizoounganishwa na kituo) wanaweza kutuma.',
              style: nyihaNunito(context, size: 11, color: muted),
            ),
            value: app.jamiiCommunityChatMembersCanSend,
            onChanged: (v) => app.setJamiiCommunityChatMembersCanSend(v),
          ),
        ),
        const SizedBox(height: 20),
        Text('Nambari za msimamizi zinazoruhusiwa kutuma', style: nyihaSectionLabel(context)),
        const SizedBox(height: 6),
        Text(
          'Wakati mazungumzo yamefungwa, ni simu hizi tu (programu ya wanajamii) zinazoweza kutuma.',
          style: nyihaNunito(context, size: 11, color: muted),
        ),
        const SizedBox(height: 10),
        ...app.adminTeam.where((a) => a.linkedMemberPhone != null).map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.phone_in_talk_rounded, color: ax, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(app.adminSeatLabelFor(a), style: nyihaNunito(context, size: 10, weight: FontWeight.w800, color: ax)),
                            Text(a.displayName, style: nyihaNunito(context, size: 13, weight: FontWeight.w700)),
                            Text(a.linkedMemberPhone!, style: nyihaNunito(context, size: 12, color: muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        if (app.adminTeam.every((a) => a.linkedMemberPhone == null))
          Text('Hakuna nambari iliyounganishwa (ongeza kwenye msimbo wa backend/konfigi).', style: nyihaNunito(context, size: 12, color: muted)),
        const SizedBox(height: 20),
        Text('Hakiki ya ujumbe', style: nyihaCinzel(context, size: 15)),
        const SizedBox(height: 8),
        if (app.messagesCommunity.isEmpty)
          Text('Hakuna ujumbe bado.', style: nyihaNunito(context, size: 13, color: muted))
        else
          ...preview.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${m.from} · ${m.time}', style: nyihaNunito(context, size: 10, color: muted)),
                    const SizedBox(height: 4),
                    Text(
                      _jamiiChatPreviewLine(m),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: nyihaNunito(context, size: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Tick approvals + duka orders.
class AdminCommercePage extends StatelessWidget {
  const AdminCommercePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final p = app.pendingTickPayment;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text('Malipo ya Mkeka (tiki)', style: nyihaCinzel(context, size: 15)),
        const SizedBox(height: 10),
        if (p == null || p.phase != TickPaymentPhase.waitingAdminApproval)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Hakuna ombi la malipo linalosubiri uidhinishaji.',
              style: nyihaNunito(context, size: 13, color: NyihaColors.onSurfaceMuted(context)),
            ),
          )
        else
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ombi: ${p.id}', style: nyihaNunito(context, size: 12, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  'Tiki ${p.tickCount} · TZS ${p.tickCount * AppState.tickPriceTzs}',
                  style: nyihaNunito(context, size: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          app.adminApprovePendingTickPayment();
                          showNyihaToast(context, 'Malipo yameidhinishwa.');
                        },
                        child: const Text('Idhinisha'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          app.adminRejectPendingTickPayment();
                          showNyihaToast(context, 'Ombi limekataliwa.');
                        },
                        child: const Text('Kataa'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        Text('Oda za Duka', style: nyihaCinzel(context, size: 15)),
        const SizedBox(height: 8),
        if (app.shopOrders.isEmpty)
          Text('Hakuna oda bado.', style: nyihaNunito(context, size: 13, color: NyihaColors.onSurfaceMuted(context)))
        else
          ...app.shopOrders.asMap().entries.map((e) {
            final i = e.key;
            final o = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.productName, style: nyihaNunito(context, size: 13, weight: FontWeight.w700)),
                    Text('Mnunuzi: ${o.buyerName}', style: nyihaNunito(context, size: 11, color: NyihaColors.accent(context))),
                    Text('${o.size} · ${o.rangi} ×${o.idadi}', style: nyihaNunito(context, size: 12)),
                    Text(o.priceLabel, style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context))),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: o.status,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'inasubiri malipo', child: Text('Inasubiri malipo')),
                        DropdownMenuItem(value: 'imeidhinishwa', child: Text('Imeidhinishwa')),
                        DropdownMenuItem(value: 'imepokelewa', child: Text('Imepokelewa')),
                        DropdownMenuItem(value: 'imefungwa', child: Text('Imefungwa')),
                      ],
                      onChanged: (v) {
                        if (v != null) app.adminSetOrderStatus(i, v);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

/// Mpangilio (akaunti, huduma, tangazo, timu) na Admin Posts (matukio + machapisho).
class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final _broadcast = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pin = TextEditingController();
  TextEditingController? _ccPhone;
  TextEditingController? _ccWa;
  TextEditingController? _ccHours;

  final _eTitle = TextEditingController();
  final _eDesc = TextEditingController();
  final _eDate = TextEditingController();
  final _eTag = TextEditingController();

  final _mHead = TextEditingController();
  final _mBody = TextEditingController();
  final _mTag = TextEditingController();
  final _mImage = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final app = context.read<AppState>();
    _ccPhone ??= TextEditingController(text: app.customerCarePhone);
    _ccWa ??= TextEditingController(text: app.customerCareWhatsApp);
    _ccHours ??= TextEditingController(text: app.customerCareHoursLabel);
  }

  @override
  void dispose() {
    _broadcast.dispose();
    _name.dispose();
    _email.dispose();
    _pin.dispose();
    _ccPhone?.dispose();
    _ccWa?.dispose();
    _ccHours?.dispose();
    _eTitle.dispose();
    _eDesc.dispose();
    _eDate.dispose();
    _eTag.dispose();
    _mHead.dispose();
    _mBody.dispose();
    _mTag.dispose();
    _mImage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final ax = NyihaColors.accent(context);
    final muted = NyihaColors.onSurfaceMuted(context);
    final session = app.adminSession;
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            labelColor: ax,
            unselectedLabelColor: muted,
            indicatorColor: ax,
            labelStyle: nyihaNunito(context, size: 12, weight: FontWeight.w800),
            tabs: const [
              Tab(text: 'Mpangilio'),
              Tab(text: 'Admin Posts'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
        Text('Akaunti yako', style: nyihaCinzel(context, size: 15)),
        const SizedBox(height: 8),
        if (session != null)
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: ax.withOpacity(0.2),
                  child: Icon(
                    session.role == AdminRole.main ? Icons.shield_rounded : Icons.support_agent_rounded,
                    color: ax,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.adminSessionSeatLabel,
                        style: nyihaNunito(context, size: 11, weight: FontWeight.w800, color: ax),
                      ),
                      Text(
                        session.displayName,
                        style: nyihaCinzel(context, size: 17),
                      ),
                      Text(
                        session.email,
                        style: nyihaNunito(context, size: 11, color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        Text('Nambari za huduma kwa wateja', style: nyihaCinzel(context, size: 15)),
        const SizedBox(height: 6),
        Text(
          'Zinaonekana kwa watumiaji wanaosubiri idhini ya uanachama (skrini ya "Subiri uidhinishaji").',
          style: nyihaNunito(context, size: 12, color: muted),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ccPhone,
          keyboardType: TextInputType.phone,
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
          decoration: const InputDecoration(
            labelText: 'Simu ya msaada',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _ccWa,
          keyboardType: TextInputType.phone,
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
          decoration: const InputDecoration(
            labelText: 'WhatsApp',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _ccHours,
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
          decoration: const InputDecoration(
            labelText: 'Masaa / maelezo mafupi',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            app.setCustomerCare(
              phone: _ccPhone?.text,
              whatsapp: _ccWa?.text,
              hoursLabel: _ccHours?.text,
            );
            showNyihaToast(context, 'Nambari zimehifadhiwa.');
          },
          icon: const Icon(Icons.save_outlined),
          label: const Text('Hifadhi nambari'),
        ),
        const SizedBox(height: 20),
        Text('Tangazo la haraka kwa njia ya Admin', style: nyihaCinzel(context, size: 15)),
        const SizedBox(height: 8),
        TextField(
          controller: _broadcast,
          minLines: 2,
          maxLines: 4,
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
          decoration: InputDecoration(
            hintText: 'Andika ujumbe utakaoona kwenye "Mazungumzo na Admin"...',
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {
            app.broadcastAdminNotice(_broadcast.text);
            _broadcast.clear();
            showNyihaToast(context, 'Ujumbe umetumwa kwenye mazungumzo ya Admin.');
          },
          icon: const Icon(Icons.send_rounded),
          label: const Text('Tuma kwa wanajamii'),
        ),
        const SizedBox(height: 28),
        Text('Timu ya wasimamizi (hadi 3)', style: nyihaCinzel(context, size: 15)),
        const SizedBox(height: 8),
        Text(
          'Mkuu mmoja anaweza kuongeza wasaidizi wawili. Wasaidizi wanaweza kufanya kila kitu isipokuwa kuongeza au kuondoa wasimamizi wengine.',
          style: nyihaNunito(context, size: 12, color: muted),
        ),
        const SizedBox(height: 16),
        ...app.adminTeam.map((a) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    a.role == AdminRole.main ? Icons.verified_rounded : Icons.support_agent_rounded,
                    color: ax,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.displayName, style: nyihaNunito(context, size: 14, weight: FontWeight.w700)),
                        Text(a.email, style: nyihaNunito(context, size: 11, color: muted)),
                        Text(
                          app.adminSeatLabelFor(a),
                          style: nyihaNunito(context, size: 10, color: ax),
                        ),
                      ],
                    ),
                  ),
                  if (app.isMainAdminSession && a.role == AdminRole.helper)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () {
                        app.removeHelperAdmin(a.id);
                        showNyihaToast(context, 'Msaidizi ameondolewa.');
                      },
                    ),
                ],
              ),
            ),
          );
        }),
        if (app.isMainAdminSession && app.canAddHelperAdmin) ...[
          const SizedBox(height: 16),
          Text('Ongeza msaidizi', style: nyihaCinzel(context, size: 15)),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Jina kamili'),
            style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Barua pepe ya kuingia'),
            keyboardType: TextInputType.emailAddress,
            style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pin,
            decoration: const InputDecoration(labelText: 'PIN (demo)'),
            keyboardType: TextInputType.number,
            obscureText: true,
            style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              final ok = app.addHelperAdmin(
                displayName: _name.text,
                email: _email.text,
                pin: _pin.text,
              );
              if (ok) {
                _name.clear();
                _email.clear();
                _pin.clear();
                showNyihaToast(context, 'Msaidizi ameongezwa.');
              } else {
                showNyihaToast(context, 'Haiwezekani. Jaza sehemu au nafasi imejaa.');
              }
            },
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Hifadhi msaidizi'),
          ),
        ] else if (!app.isMainAdminSession)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Ni mkuu tu anaweza kuongeza wasaidizi.',
              style: nyihaNunito(context, size: 12, color: muted),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Nafasi ya wasaidizi imejaa (2/2).',
              style: nyihaNunito(context, size: 12, color: muted),
            ),
          ),
                  ],
                ),
                _buildAdminPostsTab(context, app),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminPostsTab(BuildContext context, AppState app) {
    final ax = NyihaColors.accent(context);
    final muted = NyihaColors.onSurfaceMuted(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text('Maudhui ya programu ya wanajamii', style: nyihaCinzel(context, size: 15)),
        const SizedBox(height: 8),
        Text(
          'Chapisha matukio ya kalenda na machapisho ya kijamii (msiba, sherehe, n.k.) — yanaonekana kwenye Nyumbani na Matangazo.',
          style: nyihaNunito(context, size: 12, color: muted),
        ),
        const SizedBox(height: 20),
        Text('Matukio ya jamii (kalenda)', style: nyihaSectionLabel(context)),
        const SizedBox(height: 8),
        Text(
          'Matangazo ya tarehe (mikutano, harusi, msaada, n.k.) kwenye sehemu ya Matangazo.',
          style: nyihaNunito(context, size: 11, color: muted),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _eTitle,
          decoration: const InputDecoration(labelText: 'Kichwa'),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _eDesc,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Maelezo'),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _eDate,
          decoration: const InputDecoration(labelText: 'Tarehe (mf. 15 Agosti 2025)'),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _eTag,
          decoration: const InputDecoration(labelText: 'Lebo (mf. Mkutano, Sherehe)'),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () {
            app.addJamiiEvent(
              title: _eTitle.text,
              desc: _eDesc.text,
              date: _eDate.text,
              tag: _eTag.text,
            );
            _eTitle.clear();
            _eDesc.clear();
            _eDate.clear();
            _eTag.clear();
            showNyihaToast(context, 'Tukio limeongezwa.');
          },
          icon: const Icon(Icons.event_outlined),
          label: const Text('Ongeza tukio'),
        ),
        const SizedBox(height: 16),
        Text('Matukio (${app.jamiiEvents.length})', style: nyihaSectionLabel(context)),
        const SizedBox(height: 8),
        if (app.jamiiEvents.isEmpty)
          Text('Hakuna bado.', style: nyihaNunito(context, size: 13, color: muted))
        else
          ...app.jamiiEvents.asMap().entries.map((e) {
            final i = e.key;
            final ev = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ev.title, style: nyihaNunito(context, size: 13, weight: FontWeight.w700)),
                          Text(ev.tag, style: nyihaNunito(context, size: 10, color: ax)),
                          Text(ev.desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: nyihaNunito(context, size: 11, color: muted)),
                          Text('📅 ${ev.date}', style: nyihaNunito(context, size: 10, color: ax.withOpacity(0.85))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () {
                        app.removeJamiiEventAt(i);
                        showNyihaToast(context, 'Tukio limefutwa.');
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 28),
        Text('Machapisho & matangazo ya kijamii', style: nyihaSectionLabel(context)),
        const SizedBox(height: 8),
        Text(
          'Machapisho yenye picha (msiba, mkutano, sherehe, n.k.) — sehemu ya Matukio ya jamii kwenye programu.',
          style: nyihaNunito(context, size: 11, color: muted),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _mHead,
          decoration: const InputDecoration(labelText: 'Kichwa'),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _mBody,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'Maelezo'),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _mTag,
          decoration: const InputDecoration(labelText: 'Lebo (mf. Msiba, Sherehe)'),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _mImage,
          decoration: const InputDecoration(labelText: 'URL ya picha (si lazima)'),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () {
            app.addMatangazoPost(
              headline: _mHead.text,
              body: _mBody.text,
              tag: _mTag.text,
              imageUrl: _mImage.text.isEmpty ? null : _mImage.text,
            );
            _mHead.clear();
            _mBody.clear();
            _mTag.clear();
            _mImage.clear();
            showNyihaToast(context, 'Tangazo limechapishwa.');
          },
          icon: const Icon(Icons.campaign_rounded),
          label: const Text('Chapisha tangazo'),
        ),
        const SizedBox(height: 20),
        Text('Machapisho (${app.matangazoPosts.length})', style: nyihaSectionLabel(context)),
        const SizedBox(height: 8),
        ...app.matangazoPosts.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.headline, style: nyihaNunito(context, size: 13, weight: FontWeight.w700)),
                        Text(p.tag, style: nyihaNunito(context, size: 10, color: ax)),
                        Text(
                          p.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: nyihaNunito(context, size: 11, color: muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () {
                      app.removeMatangazoAt(i);
                      showNyihaToast(context, 'Tangazo limefutwa.');
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Duka: bidhaa na oda za wateja — kinachoonekana kwenye programu ya wanajamii.
class AdminDukaMatangazoPage extends StatefulWidget {
  const AdminDukaMatangazoPage({super.key});

  @override
  State<AdminDukaMatangazoPage> createState() => _AdminDukaMatangazoPageState();
}

class _AdminDukaMatangazoPageState extends State<AdminDukaMatangazoPage> {
  final _pName = TextEditingController();
  final _pPrice = TextEditingController();
  final _pEmoji = TextEditingController(text: '🛍️');
  final _pImage = TextEditingController();

  @override
  void dispose() {
    _pName.dispose();
    _pPrice.dispose();
    _pEmoji.dispose();
    _pImage.dispose();
    super.dispose();
  }

  static String _formatOrderTime(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showEditProductDialog(BuildContext context, AppState app, int index, MockProduct p) async {
    final name = TextEditingController(text: p.name);
    final price = TextEditingController(text: p.priceLabel);
    final emoji = TextEditingController(text: p.emoji);
    final image = TextEditingController(text: p.imageUrl);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hariri bidhaa', style: nyihaCinzel(ctx, size: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Jina la bidhaa'),
                style: nyihaNunito(ctx, color: NyihaColors.onSurface(ctx)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: price,
                decoration: const InputDecoration(labelText: 'Bei'),
                style: nyihaNunito(ctx, color: NyihaColors.onSurface(ctx)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emoji,
                decoration: const InputDecoration(labelText: 'Emoji'),
                style: nyihaNunito(ctx, color: NyihaColors.onSurface(ctx)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: image,
                decoration: const InputDecoration(labelText: 'URL ya picha'),
                style: nyihaNunito(ctx, color: NyihaColors.onSurface(ctx)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Ghairi')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hifadhi')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      app.updateDukaProductAt(
        index,
        name: name.text,
        priceLabel: price.text,
        emoji: emoji.text,
        imageUrl: image.text,
        color: p.color,
      );
      showNyihaToast(context, 'Bidhaa imesasishwa.');
    }
    name.dispose();
    price.dispose();
    emoji.dispose();
    image.dispose();
  }

  void _openBuyerReplySheet(BuildContext context, PlacedShopOrder order) {
    final replyCtrl = TextEditingController();
    final scroll = ScrollController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, _) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                color: isDark ? NyihaColors.earth850 : NyihaColors.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: NyihaColors.accent(ctx).withOpacity(0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jibu mteja', style: nyihaCinzel(ctx, size: 18)),
                        Text(
                          '${order.buyerName} · ${order.productName} · ${_formatOrderTime(order.placedAt)}',
                          style: nyihaNunito(ctx, size: 11, color: NyihaColors.onSurfaceMuted(ctx)),
                        ),
                        Text(
                          'Oda: ${order.id}',
                          style: nyihaNunito(ctx, size: 10, color: NyihaColors.onSurfaceMuted(ctx)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Consumer<AppState>(
                      builder: (context, app, _) {
                        final msgs = app.messagesSeller;
                        return ListView.builder(
                          controller: scroll,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          itemCount: msgs.length,
                          itemBuilder: (_, i) {
                            final m = msgs[i];
                            final mine = m.me;
                            return Align(
                              alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(ctx).size.width * 0.82),
                                decoration: BoxDecoration(
                                  color: mine
                                      ? NyihaColors.accent(ctx).withOpacity(0.22)
                                      : NyihaColors.accent(ctx).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${m.from} · ${m.time}',
                                      style: nyihaNunito(ctx, size: 10, color: NyihaColors.onSurfaceMuted(ctx)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(m.text, style: nyihaNunito(ctx, size: 13)),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: replyCtrl,
                              minLines: 1,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Andika jibu kwa mnunuzi…',
                                filled: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              style: nyihaNunito(ctx, color: NyihaColors.onSurface(ctx)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: () {
                              final t = replyCtrl.text.trim();
                              if (t.isEmpty) return;
                              context.read<AppState>().adminSendSellerReply(t);
                              replyCtrl.clear();
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (scroll.hasClients) {
                                  scroll.animateTo(
                                    scroll.position.maxScrollExtent + 80,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                  );
                                }
                              });
                            },
                            icon: const Icon(Icons.send_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      replyCtrl.dispose();
      scroll.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final ax = NyihaColors.accent(context);
    final muted = NyihaColors.onSurfaceMuted(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            labelColor: ax,
            unselectedLabelColor: muted,
            indicatorColor: ax,
            labelStyle: nyihaNunito(context, size: 12, weight: FontWeight.w800),
            tabs: const [
              Tab(text: 'Bidhaa'),
              Tab(text: 'Oda'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBidhaaTab(context, app),
                _buildOdaTab(context, app),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidhaaTab(BuildContext context, AppState app) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text('Bidhaa zinazopatikana', style: nyihaCinzel(context, size: 15)),
        const SizedBox(height: 6),
        Text(
          'Ongeza, hariri, au futa bidhaa — zitaonekana mara moja kwenye Duka na karousel ya nyumbani.',
          style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context)),
        ),
        const SizedBox(height: 14),
        Text('Ongeza bidhaa mpya', style: nyihaSectionLabel(context)),
        const SizedBox(height: 8),
        TextField(
          controller: _pName,
          decoration: const InputDecoration(labelText: 'Jina la bidhaa'),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _pPrice,
          decoration: const InputDecoration(labelText: 'Bei (mf. TZS 25,000)'),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _pEmoji,
          decoration: const InputDecoration(labelText: 'Emoji'),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _pImage,
          decoration: const InputDecoration(labelText: 'URL ya picha', hintText: 'https://...'),
          style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () {
            app.addDukaProduct(
              name: _pName.text,
              priceLabel: _pPrice.text,
              emoji: _pEmoji.text,
              imageUrl: _pImage.text,
            );
            _pName.clear();
            _pPrice.clear();
            _pEmoji.text = '🛍️';
            _pImage.clear();
            showNyihaToast(context, 'Bidhaa imeongezwa kwenye duka.');
          },
          icon: const Icon(Icons.add_shopping_cart_rounded),
          label: const Text('Ongeza bidhaa'),
        ),
        const SizedBox(height: 22),
        Text('Orodha (${app.dukaProducts.length})', style: nyihaSectionLabel(context)),
        const SizedBox(height: 8),
        if (app.dukaProducts.isEmpty)
          Text('Hakuna bidhaa bado.', style: nyihaNunito(context, size: 13, color: NyihaColors.onSurfaceMuted(context)))
        else
          ...app.dukaProducts.asMap().entries.map((e) {
            final i = e.key;
            final p = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: nyihaNunito(context, size: 13, weight: FontWeight.w700)),
                          Text(p.priceLabel, style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context))),
                          const SizedBox(height: 4),
                          Text(
                            p.imageUrl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: nyihaNunito(context, size: 9, color: NyihaColors.onSurfaceMuted(context)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: NyihaColors.accent(context)),
                      tooltip: 'Hariri',
                      onPressed: () => _showEditProductDialog(context, app, i, p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: 'Futa',
                      onPressed: () {
                        app.removeDukaProductAt(i);
                        showNyihaToast(context, 'Imeondolewa.');
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildOdaTab(BuildContext context, AppState app) {
    const statusItems = [
      DropdownMenuItem(value: 'inasubiri malipo', child: Text('Inasubiri malipo')),
      DropdownMenuItem(value: 'imeidhinishwa', child: Text('Imeidhinishwa')),
      DropdownMenuItem(value: 'imepokelewa', child: Text('Imepokelewa')),
      DropdownMenuItem(value: 'imefungwa', child: Text('Imefungwa')),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text('Oda za wanunuzi', style: nyihaCinzel(context, size: 15)),
        const SizedBox(height: 6),
        Text(
          'Fuatilia hali ya oda na jibu mteja kupitia mazungumzo ya duka (yanayoonekana pia kwa mnunuzi).',
          style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context)),
        ),
        const SizedBox(height: 16),
        if (app.shopOrders.isEmpty)
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Bado hakuna oda.',
                  style: nyihaNunito(context, size: 14, color: NyihaColors.onSurfaceMuted(context)),
                ),
              ),
            ),
          )
        else
          ...app.shopOrders.asMap().entries.map((e) {
            final i = e.key;
            final o = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            o.productName,
                            style: nyihaNunito(context, size: 14, weight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          o.id,
                          style: nyihaNunito(context, size: 10, color: NyihaColors.onSurfaceMuted(context)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Mnunuzi: ${o.buyerName}',
                      style: nyihaNunito(context, size: 12, weight: FontWeight.w700, color: NyihaColors.accent(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${o.size} · ${o.rangi} · ×${o.idadi} · ${o.priceLabel}',
                      style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context)),
                    ),
                    Text(
                      _formatOrderTime(o.placedAt),
                      style: nyihaNunito(context, size: 11, color: NyihaColors.onSurfaceMuted(context)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: o.status,
                            isExpanded: true,
                            items: statusItems,
                            onChanged: (v) {
                              if (v != null) app.adminSetOrderStatus(i, v);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => _openBuyerReplySheet(context, o),
                          icon: const Icon(Icons.reply_rounded, size: 18),
                          label: const Text('Jibu'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

}
