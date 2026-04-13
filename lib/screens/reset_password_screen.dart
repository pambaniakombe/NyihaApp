import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import '../widgets/auth_sign_in_shell.dart';
import '../widgets/glass_card.dart';
import '../widgets/kente_strip.dart';
import '../widgets/nyiha_buttons.dart';
import '../widgets/nyiha_toast.dart';

/// Set a new password using the token from the reset email (append to app or paste here).
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.initialToken});

  final String? initialToken;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final TextEditingController _token = TextEditingController(text: widget.initialToken ?? '');
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _token.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = _token.text.trim();
    final p1 = _pass.text;
    final p2 = _pass2.text;
    if (t.isEmpty) {
      showNyihaToast(context, 'Weka kifaa cha kiungo kutoka barua pepe.');
      return;
    }
    if (p1.length < 8) {
      showNyihaToast(context, 'Nenosiri lazima liwe angalau herufi 8.');
      return;
    }
    if (p1 != p2) {
      showNyihaToast(context, 'Nenosiri hazifanani.');
      return;
    }
    setState(() => _busy = true);
    final app = context.read<AppState>();
    final ok = await app.resetPasswordWithToken(t, p1);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      showNyihaToast(context, 'Nenosiri limebadilishwa. Sasa unaweza kuingia.');
      app.setScreen(AppScreen.login);
    } else {
      showNyihaToast(context, app.lastApiError ?? 'Hitilafu.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ax = NyihaColors.accent(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: NyihaDecorations.pageGradient(context),
          ),
          Positioned.fill(child: DecoratedBox(decoration: NyihaDecorations.subtleRadialAccent(context))),
          Column(
            children: [
              const KenteStrip(height: 5),
              Expanded(
                child: AuthSignInShell(
                  maxWidth: 440,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Nenosiri jipya',
                        textAlign: TextAlign.center,
                        style: nyihaCinzel(context, size: 26),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bandika kifaa kutoka kiungo kilichotumwa kwenye barua pepe yako.',
                        textAlign: TextAlign.center,
                        style: nyihaNunito(context, size: 14, color: NyihaColors.onSurfaceMuted(context)),
                      ),
                      const SizedBox(height: 28),
                      GlassCard(
                        borderRadius: 24,
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('KIFAA / TOKEN', style: nyihaFieldLabel(context)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _token,
                              minLines: 1,
                              maxLines: 3,
                              style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
                              decoration: authInputDecoration(
                                context,
                                hintText: '…',
                                prefixIcon: Icon(Icons.link_rounded, color: ax),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text('NENOSIRI JIPYA', style: nyihaFieldLabel(context)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _pass,
                              obscureText: _obscure,
                              style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
                              decoration: authInputDecoration(
                                context,
                                hintText: '••••••••',
                                prefixIcon: Icon(Icons.lock_rounded, color: ax),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    color: NyihaColors.goldMuted,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('THIBITISHA', style: nyihaFieldLabel(context)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _pass2,
                              obscureText: _obscure,
                              style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
                              decoration: authInputDecoration(
                                context,
                                hintText: '••••••••',
                                prefixIcon: Icon(Icons.lock_outline_rounded, color: ax),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      BtnGold(
                        label: _busy ? 'Inatumika...' : 'Badili nenosiri',
                        icon: Icons.check_rounded,
                        onPressed: _busy ? null : _submit,
                      ),
                      const SizedBox(height: 12),
                      BtnOutline(
                        label: 'Rudi kwenye kuingia',
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => context.read<AppState>().setScreen(AppScreen.login),
                      ),
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
}
