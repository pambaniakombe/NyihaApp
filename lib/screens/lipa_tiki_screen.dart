import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import '../widgets/glass_card.dart';
import '../widgets/nyiha_buttons.dart';
import '../widgets/nyiha_toast.dart';

void openLipaTikiScreen(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (context) => const LipaTikiScreen()),
  );
}

class LipaTikiScreen extends StatefulWidget {
  const LipaTikiScreen({super.key});

  @override
  State<LipaTikiScreen> createState() => _LipaTikiScreenState();
}

class _LipaTikiScreenState extends State<LipaTikiScreen> {
  double _sliderTicks = 1;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final u = app.user;
    final first = u.name.split(' ').first;
    final req = AppState.ticksRequiredAnnual;
    final paid = u.ticksPaid;
    final owed = app.ticksOwedAnnual;
    final price = AppState.tickPriceTzs;
    final pending = app.pendingTickPayment;
    final tc2 = NyihaColors.onSurfaceMuted(context);
    final ax = NyihaColors.accent(context);

    if (owed > 0 && _sliderTicks > owed) {
      _sliderTicks = owed.toDouble();
    }
    if (owed > 0 && _sliderTicks < 1) {
      _sliderTicks = 1;
    }

    final selected = owed > 0 ? _sliderTicks.round().clamp(1, owed) : 0;
    final totalTzs = selected * price;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? NyihaColors.earth900 : NyihaColors.lightSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: NyihaColors.onSurface(context),
        elevation: 0,
        title: Text('Lipa tiki', style: nyihaCinzel(context, size: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Habari $first 👋',
                  style: nyihaCinzel(context, size: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Umelipia tiki $paid kati ya tiki $req kwa mwaka huu.',
                  style: nyihaNunito(context, size: 14, height: 1.45, color: NyihaColors.onSurface(context)),
                ),
                const SizedBox(height: 8),
                Text(
                  owed > 0 ? 'Unadaiwa tiki $owed.' : 'Hongera! Umekamilisha malipo ya tiki za mwaka.',
                  style: nyihaNunito(
                    context,
                    size: 14,
                    weight: FontWeight.w700,
                    color: owed > 0 ? ax : NyihaColors.greenAccent,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: req == 0 ? 0 : paid / req,
                    minHeight: 8,
                    backgroundColor: ax.withOpacity(0.12),
                    color: ax,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bei: TZS ${_fmt(price)} kwa kila tiki',
                  style: nyihaNunito(context, size: 12, color: tc2),
                ),
              ],
            ),
          ),
          if (pending != null) ...[
            const SizedBox(height: 18),
            _PendingCard(
              pending: pending,
              price: price,
              onConfirmMoney: () {
                app.confirmTickMoneyReceived();
                showNyihaToast(context, 'Malipo yamepokelewa. Subiri admin.');
              },
              onAdminApprove: () {
                app.adminApprovePendingTickPayment();
                showNyihaToast(context, 'Tiki zimeongezwa kwenye akaunti yako!');
                setState(() => _sliderTicks = 1);
              },
            ),
          ] else if (owed > 0) ...[
            const SizedBox(height: 18),
            Text('Chagua idadi ya tiki unayotaka kulipa', style: nyihaCinzel(context, size: 16)),
            const SizedBox(height: 8),
            Text(
              'Kisha utasubiri malipo yafike, halafu admin atathibitisha.',
              style: nyihaNunito(context, size: 12, color: tc2),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tiki', style: nyihaNunito(context, size: 14, weight: FontWeight.w700)),
                      Text(
                        '$selected',
                        style: nyihaCinzel(context, size: 28, weight: FontWeight.w800, color: ax),
                      ),
                    ],
                  ),
                  if (owed > 1) ...[
                    Slider(
                      value: _sliderTicks.clamp(1, owed.toDouble()),
                      min: 1,
                      max: owed.toDouble(),
                      divisions: owed - 1,
                      label: '$selected',
                      activeColor: ax,
                      onChanged: (v) => setState(() => _sliderTicks = v),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Divider(color: ax.withOpacity(0.12)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jumla ya kulipa', style: nyihaNunito(context, size: 13, color: tc2)),
                      Text(
                        'TZS ${_fmt(totalTzs)}',
                        style: nyihaCinzel(context, size: 18, weight: FontWeight.w700, color: ax),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            BtnGold(
              label: 'Tuma ombi la malipo',
              icon: Icons.send_rounded,
              onPressed: () {
                final ok = app.submitTickPaymentRequest(selected);
                if (!ok) {
                  showNyihaToast(context, 'Haiwezekani. Jaribu tena.');
                  return;
                }
                showNyihaToast(context, 'Ombi limetumwa. Fuata maelekezo ya malipo.');
                setState(() {});
              },
            ),
          ],
        ],
      ),
    );
  }

  static String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.pending,
    required this.price,
    required this.onConfirmMoney,
    required this.onAdminApprove,
  });

  final PendingTickPayment pending;
  final int price;
  final VoidCallback onConfirmMoney;
  final VoidCallback onAdminApprove;

  static String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ax = NyihaColors.accent(context);
    final tc2 = NyihaColors.onSurfaceMuted(context);
    final total = pending.tickCount * price;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: ax),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pending.phase == TickPaymentPhase.waitingMoney
                      ? 'Inasubiri malipo'
                      : 'Inasubiri uidhinishaji wa admin',
                  style: nyihaCinzel(context, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ombi: tiki ${pending.tickCount} · TZS ${_fmt(total)}',
            style: nyihaNunito(context, size: 14, weight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text('Nambari ya kumbukumbu: ${pending.id}', style: nyihaNunito(context, size: 12, color: tc2)),
          const SizedBox(height: 14),
          if (pending.phase == TickPaymentPhase.waitingMoney) ...[
            Text(
              'Tuma TZS ${_fmt(total)} kupitia M-Pesa (paybill au nambari ya jamii). Baada ya kutuma, bonyeza hapa.',
              style: nyihaNunito(context, size: 13, height: 1.5, color: NyihaColors.onSurface(context)),
            ),
            const SizedBox(height: 14),
            BtnGold(
              label: 'Nimeweka fedha / malipo yamepokelewa',
              icon: Icons.payments_rounded,
              onPressed: onConfirmMoney,
            ),
          ] else ...[
            Text(
              'Fedha imepokelewa kwa akaunti ya jamii. Msimamizi atathibitisha na tiki zitaongezwa.',
              style: nyihaNunito(context, size: 13, height: 1.5, color: NyihaColors.onSurface(context)),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onAdminApprove,
              icon: const Icon(Icons.verified_user_rounded, size: 20),
              label: const Text('Thibitisha malipo (admin)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: ax,
                side: BorderSide(color: ax.withOpacity(0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Katika mfumo halisi, hatua hii inafanywa na admin pekee.',
              style: nyihaNunito(context, size: 11, color: tc2),
            ),
          ],
        ],
      ),
    );
  }
}
