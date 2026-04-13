import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'register_screen.dart';
import 'terms_screen.dart';
import 'payment_screen.dart';
import 'login_screen.dart';
import 'reset_password_screen.dart';
import 'main_shell.dart';
import 'pending_approval_screen.dart';

class RootShell extends StatelessWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, _) {
        switch (app.screen) {
          case AppScreen.splash:
            return const SplashScreen();
          case AppScreen.onboarding:
            return const OnboardingScreen();
          case AppScreen.register:
            return const RegisterScreen();
          case AppScreen.terms:
            return const TermsScreen();
          case AppScreen.payment:
            return const PaymentScreen();
          case AppScreen.login:
            return const LoginScreen();
          case AppScreen.resetPassword:
            return const ResetPasswordScreen();
          case AppScreen.main:
            if (!app.isMemberApproved) {
              return const PendingApprovalScreen();
            }
            return const MainShell();
          case AppScreen.pendingApproval:
            return const PendingApprovalScreen();
          case AppScreen.adminLogin:
          case AppScreen.adminMain:
            // Member app does not host the admin console — use the separate `admins` project.
            return const _ResetAdminScreenToLogin();
        }
      },
    );
  }
}

/// If [AppScreen] is ever set to admin routes in the member app, reset to login.
class _ResetAdminScreenToLogin extends StatefulWidget {
  const _ResetAdminScreenToLogin();

  @override
  State<_ResetAdminScreenToLogin> createState() => _ResetAdminScreenToLoginState();
}

class _ResetAdminScreenToLoginState extends State<_ResetAdminScreenToLogin> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppState>().setScreen(AppScreen.login);
    });
  }

  @override
  Widget build(BuildContext context) => const LoginScreen();
}
