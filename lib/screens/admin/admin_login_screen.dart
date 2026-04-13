import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../theme/nyiha_colors.dart';
import '../../theme/nyiha_text.dart';
import '../../widgets/auth_sign_in_shell.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kente_strip.dart';
import '../../widgets/nyiha_buttons.dart';
import '../../widgets/nyiha_toast.dart';

/// Secure entry to the administrator console (demo PIN — replace with backend auth).
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _email = TextEditingController(text: 'mkuu@nyiha.app');
  final _pin = TextEditingController(text: '0000');
  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final e = _email.text.trim();
    final p = _pin.text.trim();
    if (e.isEmpty || p.isEmpty) {
      showNyihaToast(context, 'Jaza barua pepe na PIN.');
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final app = context.read<AppState>();
    final ok = app.loginAdmin(email: e, pin: p);
    setState(() => _busy = false);
    if (!mounted) return;
    if (ok) {
      app.setScreen(AppScreen.adminMain);
      showNyihaToast(context, 'Karibu, ${app.adminSession!.displayName}.');
    } else {
      showNyihaToast(context, 'Barua pepe au PIN si sahihi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ax = NyihaColors.accent(context);
    final standalone = context.watch<AppState>().isAdminStandaloneOnly;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0618),
                  Color(0xFF1A0A2E),
                  NyihaColors.earth900,
                  Color(0xFF151008),
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -40,
            child: Icon(Icons.hexagon_outlined, size: 220, color: ax.withOpacity(0.06)),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: Icon(Icons.shield_outlined, size: 180, color: ax.withOpacity(0.05)),
          ),
          Column(
            children: [
              const KenteStrip(height: 5),
              Expanded(
                child: AuthSignInShell(
                  maxWidth: 440,
                  horizontalPadding: 28,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              colors: [ax.withOpacity(0.95), NyihaColors.goldDark, ax],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(color: ax.withOpacity(0.4), blurRadius: 32, offset: const Offset(0, 14)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.admin_panel_settings_rounded, size: 46, color: Color(0xFF0A0603)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Kituo cha Wasimamizi',
                        textAlign: TextAlign.center,
                        style: nyihaCinzel(context, size: 24, color: NyihaColors.ivory),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Mkuu mmoja na wasaidizi wawili · dhibiti jamii, malipo na maudhui',
                        textAlign: TextAlign.center,
                        style: nyihaNunito(context, size: 13, color: NyihaColors.cream.withOpacity(0.65)),
                      ),
                      const SizedBox(height: 28),
                      GlassCard(
                        borderRadius: 24,
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'BARUA PEPE',
                              style: nyihaFieldLabel(context),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
                              decoration: authInputDecoration(
                                context,
                                hintText: 'mkuu@nyiha.app',
                                prefixIcon: Icon(Icons.alternate_email_rounded, color: ax),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text('PIN', style: nyihaFieldLabel(context)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _pin,
                              obscureText: _obscure,
                              keyboardType: TextInputType.number,
                              style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
                              decoration: authInputDecoration(
                                context,
                                hintText: '••••',
                                prefixIcon: Icon(Icons.pin_rounded, color: ax),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    color: NyihaColors.goldMuted,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AuthButtonColumn(
                        gap: 12,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: BtnGold(
                              label: _busy ? 'Inaingia...' : 'Ingia kwenye kituo',
                              icon: Icons.shield_rounded,
                              onPressed: _busy ? null : _submit,
                            ),
                          ),
                          if (!standalone)
                            SizedBox(
                              width: double.infinity,
                              child: BtnOutline(
                                label: 'Rudi kwenye mtumiaji',
                                icon: Icons.arrow_back_rounded,
                                onPressed: () => context.read<AppState>().setScreen(AppScreen.login),
                              ),
                            ),
                        ],
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
