import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/nyiha_colors.dart';
import '../theme/nyiha_text.dart';
import 'tabs/home_tab.dart';
import 'tabs/community_tab.dart';
import 'tabs/duka_tab.dart';
import 'tabs/profile_tab.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, _) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        // extendBody must stay false so tab content (e.g. Jamii chat composer) is laid out
        // above the bottom nav instead of hidden underneath the floating bar.
        final tabs = <(int, IconData, String)>[];
        if (app.showUserTabHome) tabs.add((0, Icons.home_rounded, 'Nyumbani'));
        if (app.showUserTabJamii) tabs.add((1, Icons.groups_rounded, 'Jamii'));
        if (app.showUserTabDuka) tabs.add((2, Icons.storefront_rounded, 'Duka'));
        if (app.showUserTabProfile) tabs.add((3, Icons.person_rounded, 'Mimi'));
        if (tabs.isEmpty) {
          tabs.add((0, Icons.home_rounded, 'Nyumbani'));
        }
        return Scaffold(
          body: IndexedStack(
            index: app.mainTabIndex.clamp(0, 3),
            children: [
              app.showUserTabHome ? const HomeTab() : const _DisabledTabPlaceholder(title: 'Nyumbani'),
              app.showUserTabJamii ? const CommunityTab() : const _DisabledTabPlaceholder(title: 'Jamii'),
              app.showUserTabDuka ? const DukaTab() : const _DisabledTabPlaceholder(title: 'Duka'),
              app.showUserTabProfile ? const ProfileTab() : const _DisabledTabPlaceholder(title: 'Mimi'),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: _BottomBar(
              dark: dark,
              tabs: tabs,
              mainTabIndex: app.mainTabIndex,
              onTap: app.setMainTab,
            ),
          ),
        );
      },
    );
  }
}

class _DisabledTabPlaceholder extends StatelessWidget {
  const _DisabledTabPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 56, color: NyihaColors.accent(context).withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Sehemu "$title" imefungwa na wasimamizi.',
              textAlign: TextAlign.center,
              style: nyihaNunito(context, size: 15, color: NyihaColors.onSurfaceMuted(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.dark,
    required this.tabs,
    required this.mainTabIndex,
    required this.onTap,
  });

  final bool dark;
  final List<(int, IconData, String)> tabs;
  final int mainTabIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: dark
                ? NyihaColors.earth850.withOpacity(0.88)
                : NyihaColors.lightSurface.withOpacity(0.94),
            border: Border.all(
              color: NyihaColors.accent(context).withOpacity(dark ? 0.22 : 0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.45 : 0.12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                for (final t in tabs)
                  _Tab(
                    icon: t.$2,
                    label: t.$3,
                    active: mainTabIndex == t.$1,
                    onTap: () => onTap(t.$1),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = NyihaColors.accent(context);
    final muted = NyihaColors.onSurfaceMuted(context);
    final c = active ? accent : muted;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: active ? accent.withOpacity(0.14) : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: active ? 24 : 21, color: c),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: nyihaNunito(
                    context,
                    size: 9,
                    weight: FontWeight.w700,
                    color: c,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
