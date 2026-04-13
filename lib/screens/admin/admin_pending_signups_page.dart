import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../theme/nyiha_colors.dart';
import '../../theme/nyiha_text.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/nyiha_toast.dart';

/// Lists [PendingSignupRequest] entries — admin confirms fee then approves or rejects.
class AdminPendingSignupsPage extends StatefulWidget {
  const AdminPendingSignupsPage({super.key});

  @override
  State<AdminPendingSignupsPage> createState() => _AdminPendingSignupsPageState();
}

class _AdminPendingSignupsPageState extends State<AdminPendingSignupsPage> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    if (_loading) return;
    setState(() => _loading = true);
    final app = context.read<AppState>();
    await app.fetchPendingSignupsApi();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final ax = NyihaColors.accent(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Watumiaji wapya', style: nyihaCinzel(context, size: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: app.pendingSignupRequests.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  _loading
                      ? 'Inapakia maombi...'
                      : 'Hakuna maombi mapya. Wanapotuma fomu na ada, yataonekana hapa.',
                  textAlign: TextAlign.center,
                  style: nyihaNunito(context, size: 14, color: NyihaColors.onSurfaceMuted(context)),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: app.pendingSignupRequests.length,
              itemBuilder: (context, i) {
                final r = app.pendingSignupRequests[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
                                r.fullName,
                                style: nyihaNunito(context, size: 16, weight: FontWeight.w800),
                              ),
                            ),
                            if (r.registrationFeePaid)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Ada (demo)',
                                  style: nyihaNunito(context, size: 10, weight: FontWeight.w700, color: Colors.green.shade700),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '@${r.username} · ${r.phone}',
                          style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context)),
                        ),
                        Text(
                          r.location,
                          style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          r.detailLines,
                          style: nyihaNunito(context, size: 11, height: 1.4, color: NyihaColors.onSurfaceMuted(context)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tuma: ${_fmt(r.submittedAt)}',
                          style: nyihaNunito(context, size: 10, color: NyihaColors.onSurfaceMuted(context)),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Hakikisha malipo ya ada yamepokelewa kabla ya kuidhinisha.',
                          style: nyihaNunito(context, size: 11, weight: FontWeight.w600, color: ax),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () async {
                                  final ok = await app.approveSignupRequestApi(r.id);
                                  if (!context.mounted) return;
                                  showNyihaToast(
                                    context,
                                    ok
                                        ? '${r.fullName} ameidhinishwa.'
                                        : (app.lastApiError ?? 'Imeshindikana kuidhinisha ombi.'),
                                  );
                                },
                                icon: const Icon(Icons.check_circle_outline_rounded),
                                label: const Text('Idhinisha'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final ok = await app.rejectSignupRequestApi(r.id);
                                  if (!context.mounted) return;
                                  showNyihaToast(
                                    context,
                                    ok
                                        ? 'Ombi limekataliwa.'
                                        : (app.lastApiError ?? 'Imeshindikana kukataa ombi.'),
                                  );
                                },
                                icon: const Icon(Icons.close_rounded),
                                label: const Text('Kataa'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ),
    );
  }

  String _fmt(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
        '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }
}
