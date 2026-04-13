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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifier = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _identifier.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final id = _identifier.text.trim();
    if (id.isEmpty || _pass.text.isEmpty) {
      showNyihaToast(context, 'Jaza nambari ya simu au barua pepe, na nenosiri.');
      return;
    }
    setState(() => _busy = true);
    final app = context.read<AppState>();
    final ok = await app.loginMemberApi(id, _pass.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      showNyihaToast(context, app.lastApiError ?? 'Huwezi kuingia kwa sasa.');
      return;
    }
    final first = app.user.name.split(' ').first;
    if (app.isMemberApproved) {
      app.setScreen(AppScreen.main);
      showNyihaToast(context, 'Karibu tena, $first!');
    } else {
      app.setScreen(AppScreen.pendingApproval);
      final st = app.user.status.trim().toLowerCase();
      final msg = switch (st) {
        'pending' => 'Akaunti yako inasubiri idhini ya msimamizi.',
        'rejected' => 'Angalia hali ya ombi lako.',
        _ => 'Karibu, $first.',
      };
      showNyihaToast(context, msg);
    }
  }

  Future<void> _forgot() async {
    final emailCtrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Nenosiri limesahaulika', style: nyihaCinzel(ctx, size: 20)),
                const SizedBox(height: 10),
                Text(
                  'Weka barua pepe ya akaunti yako. Tutakutumia nenosiri jipya kwenye barua pepe.',
                  style: nyihaNunito(ctx, size: 14, color: NyihaColors.onSurfaceMuted(ctx)),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  style: nyihaNunito(ctx, color: NyihaColors.onSurface(ctx)),
                  decoration: const InputDecoration(
                    hintText: 'jina@mfano.com',
                    prefixIcon: Icon(Icons.alternate_email_rounded, color: NyihaColors.gold),
                  ),
                ),
                const SizedBox(height: 20),
                BtnGold(
                  label: 'Tuma nenosiri jipya',
                  icon: Icons.mark_email_read_rounded,
                  onPressed: () async {
                    final em = emailCtrl.text.trim();
                    if (em.isEmpty || !em.contains('@')) {
                      showNyihaToast(ctx, 'Weka barua pepe halali.');
                      return;
                    }
                    final app = ctx.read<AppState>();
                    final ok = await app.requestPasswordResetEmail(em);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    showNyihaToast(
                      context,
                      ok
                          ? 'Ikiwa barua ipo, tumetuma nenosiri jipya kwa barua pepe.'
                          : (app.lastApiError ?? 'Hitilafu.'),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    emailCtrl.dispose();
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
                      Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            gradient: NyihaColors.primaryButtonGradient(context),
                            boxShadow: [
                              BoxShadow(
                                color: ax.withOpacity(0.35),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text('🏔️', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Karibu tena',
                        textAlign: TextAlign.center,
                        style: nyihaCinzel(context, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingia kwa simu au barua pepe',
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
                            Text('SIMU AU BARUA PEPE', style: nyihaFieldLabel(context)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _identifier,
                              keyboardType: TextInputType.text,
                              autofillHints: const [AutofillHints.username],
                              style: nyihaNunito(context, color: NyihaColors.onSurface(context)),
                              decoration: authInputDecoration(
                                context,
                                hintText: '+255… au jina@barua.com',
                                prefixIcon: Icon(Icons.person_rounded, color: ax),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text('NENOSIRI', style: nyihaFieldLabel(context)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _pass,
                              obscureText: _obscure,
                              autofillHints: const [AutofillHints.password],
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
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _forgot,
                                child: Text(
                                  'Umesahau nenosiri?',
                                  style: nyihaNunito(context, size: 13, color: ax),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.read<AppState>().setScreen(AppScreen.resetPassword),
                              child: Text(
                                'Nina token ya zamani — badili nenosiri kwa token',
                                textAlign: TextAlign.center,
                                style: nyihaNunito(context, size: 12, color: NyihaColors.onSurfaceMuted(context)),
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
                              label: _busy ? 'Inaingia...' : 'Ingia',
                              icon: Icons.login_rounded,
                              onPressed: _busy ? null : _login,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: BtnOutline(
                              label: 'Rudi',
                              icon: Icons.arrow_back_rounded,
                              onPressed: () => context.read<AppState>().setScreen(AppScreen.onboarding),
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
