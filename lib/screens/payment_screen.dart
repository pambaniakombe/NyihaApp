import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import '../widgets/glass_card.dart';
import '../widgets/kente_strip.dart';
import '../widgets/nyiha_buttons.dart';
import '../widgets/nyiha_toast.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _loading = false;
  bool _success = false;

  Future<void> _pay(String method) async {
    setState(() {
      _loading = true;
      _success = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _success = true;
    });
    showNyihaToast(context, '$method: Malipo yamefanikiwa!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(width: double.infinity, height: double.infinity, decoration: NyihaDecorations.pageGradient(context)),
          Positioned.fill(child: DecoratedBox(decoration: NyihaDecorations.subtleRadialAccent(context))),
          Column(
            children: [
              const KenteStrip(height: 5),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                  child: Column(
                    children: [
                    Text('Ada ya kujiunga', style: nyihaCinzel(context, size: 26)),
                    const SizedBox(height: 8),
                    Text(
                      'Lipia ada ya kuingia kwenye Jamii ya Nyiha',
                      style: nyihaNunito(context, size: 14, color: NyihaColors.onSurfaceMuted(context)),
                    ),
                    const SizedBox(height: 32),
                    GlassCard(
                      child: Column(
                        children: [
                          Text('TZS 20,000', style: nyihaCinzel(context, size: 44, weight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(
                            'Ada ya uanachama · malipo ya mara moja',
                            style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context)),
                          ),
                          const SizedBox(height: 16),
                          const KenteStrip(height: 4),
                          const SizedBox(height: 18),
                          _row(context, 'Ada ya uanachama', 'TZS 18,000', false),
                          _row(context, 'Mkeka — mwezi 1', 'TZS 2,000', false),
                          Divider(color: NyihaColors.gold.withOpacity(0.15)),
                          _row(context, 'Jumla', 'TZS 20,000', true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!_loading && !_success) ...[
                      _method(context, 'M-Pesa', 'Lipa kwa simu yako', const Color(0xFFE34234), Icons.phone_android_rounded, () => _pay('M-Pesa')),
                      const SizedBox(height: 12),
                      _method(context, 'Tigo Pesa', 'Malipo ya haraka', const Color(0xFF0070F3), Icons.flash_on_rounded, () => _pay('Tigo Pesa')),
                    ],
                    if (_loading) ...[
                      const SizedBox(height: 32),
                      const CircularProgressIndicator(color: NyihaColors.gold),
                      const SizedBox(height: 14),
                      Text('Inakagua malipo...', style: nyihaCinzel(context, size: 15)),
                    ],
                    if (_success) ...[
                      const SizedBox(height: 16),
                      Icon(Icons.check_circle_rounded, size: 72, color: NyihaColors.gold.withOpacity(0.95)),
                      Text('Malipo yamefanikiwa!', style: nyihaCinzel(context, size: 22)),
                      const SizedBox(height: 8),
                      Text(
                        'Ombi lako linasubiri idhini ya msimamizi.',
                        textAlign: TextAlign.center,
                        style: nyihaNunito(context, size: 14, color: NyihaColors.onSurfaceMuted(context)),
                      ),
                      const SizedBox(height: 28),
                      GlassCard(
                        child: Column(
                          children: [
                            Text('Subiri', style: nyihaCinzel(context, size: 15)),
                            const SizedBox(height: 6),
                            Text(
                              'Utaarifiwa ukikubaliwa',
                              style: nyihaNunito(context, size: 13, color: NyihaColors.onSurfaceMuted(context)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      BtnGold(
                        label: 'Tuma ombi la uanachama',
                        icon: Icons.send_rounded,
                        onPressed: () {
                          final app = context.read<AppState>();
                          app.completeRegistrationPendingApproval();
                          app.setScreen(AppScreen.pendingApproval);
                          showNyihaToast(context, 'Ombi limetumwa. Subiri idhini ya msimamizi.');
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String a, String b, bool bold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(a, style: nyihaNunito(context, size: 13, color: NyihaColors.onSurfaceMuted(context)))),
          Text(
            b,
            style: nyihaNunito(
              context,
              size: bold ? 15 : 13,
              weight: bold ? FontWeight.w700 : FontWeight.w500,
              color: bold ? NyihaColors.gold : NyihaColors.onSurface(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _method(BuildContext context, String title, String sub, Color c, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(colors: [c, c.withOpacity(0.75)]),
                boxShadow: [BoxShadow(color: c.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: nyihaNunito(context, size: 15, weight: FontWeight.w700, color: NyihaColors.onSurface(context))),
                  Text(sub, style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 28, color: NyihaColors.gold.withOpacity(0.85)),
          ],
        ),
      ),
    );
  }
}
