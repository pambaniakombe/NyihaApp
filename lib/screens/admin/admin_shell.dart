import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../theme/nyiha_colors.dart';
import '../../theme/nyiha_text.dart';
import '../../widgets/kente_strip.dart';
import 'admin_pages.dart';

/// Full-screen administrator console: overview, jumuiya, duka, mikeka, settings.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  static const _titles = [
    'Overview',
    'Jumuiya',
    'Duka',
    'Mikeka',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final idx = app.adminShellIndex.clamp(0, 4);
    final ax = NyihaColors.accent(context);

    final pages = const [
      AdminDashboardPage(),
      AdminJumuiyaPage(),
      AdminDukaMatangazoPage(),
      AdminCommercePage(),
      AdminSettingsPage(),
    ];

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  NyihaColors.earth900,
                  const Color(0xFF1A0A2E),
                  NyihaColors.earth850,
                ],
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      color: NyihaColors.cream.withOpacity(0.85),
                      tooltip: 'Toka',
                      onPressed: () {
                        context.read<AppState>()
                          ..logoutAdmin()
                          ..setScreen(AppScreen.adminLogin);
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titles[idx],
                            style: nyihaCinzel(context, size: 20, color: NyihaColors.ivory),
                          ),
                          if (app.adminSession != null) ...[
                            Text(
                              '${app.adminSessionSeatLabel} · ${app.adminSession!.displayName}',
                              style: nyihaNunito(context, size: 12, color: NyihaColors.cream.withOpacity(0.92)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              app.adminSession!.email,
                              style: nyihaNunito(context, size: 11, color: NyihaColors.cream.withOpacity(0.6)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(app.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                      color: NyihaColors.cream.withOpacity(0.85),
                      onPressed: () => context.read<AppState>().toggleTheme(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const KenteStrip(height: 4),
          Expanded(child: pages[idx]),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? NyihaColors.earth850.withOpacity(0.92)
              : NyihaColors.lightSurface.withOpacity(0.96),
          border: Border(top: BorderSide(color: ax.withOpacity(0.12))),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 72,
            selectedIndex: idx,
            onDestinationSelected: context.read<AppState>().setAdminShellIndex,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: ax.withOpacity(0.65)),
                selectedIcon: Icon(Icons.dashboard_rounded, color: ax),
                label: 'Overview',
              ),
              NavigationDestination(
                icon: Icon(Icons.groups_outlined, color: ax.withOpacity(0.65)),
                selectedIcon: Icon(Icons.groups_rounded, color: ax),
                label: 'Jumuiya',
              ),
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined, color: ax.withOpacity(0.65)),
                selectedIcon: Icon(Icons.storefront_rounded, color: ax),
                label: 'Duka',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_on_outlined, color: ax.withOpacity(0.65)),
                selectedIcon: Icon(Icons.grid_on_rounded, color: ax),
                label: 'Mikeka',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: ax.withOpacity(0.65)),
                selectedIcon: Icon(Icons.settings_rounded, color: ax),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
