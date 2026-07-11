import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  static const _tabs = [
    (path: '/dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    (path: '/members', icon: Icons.people_outlined, activeIcon: Icons.people, label: 'Members'),
    (path: '/collections', icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: 'Collections'),
    (path: '/expenses', icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Expenses'),
    (path: '/reports', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Reports'),
  ];

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    for (var i = 0; i < _tabs.length; i++) {
      if (loc.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _index(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon),
                  selectedIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
