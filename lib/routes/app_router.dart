import 'package:go_router/go_router.dart';
import '../shared/widgets/main_scaffold.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/members/presentation/members_screen.dart';
import '../features/members/presentation/member_form_screen.dart';
import '../features/members/presentation/member_detail_screen.dart';
import '../features/collections/presentation/collections_screen.dart';
import '../features/collections/presentation/collection_form_screen.dart';
import '../features/collections/presentation/collection_detail_screen.dart';
import '../features/expenses/presentation/expenses_screen.dart';
import '../features/expenses/presentation/expense_form_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (ctx, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: '/members',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: MembersScreen()),
          routes: [
            GoRoute(
              path: 'add',
              builder: (c, s) => const MemberFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (c, s) => MemberDetailScreen(
                  id: s.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (c, s) => MemberFormScreen(
                      id: s.pathParameters['id']),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/collections',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: CollectionsScreen()),
          routes: [
            GoRoute(
              path: 'add',
              builder: (c, s) => const CollectionFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (c, s) => CollectionDetailScreen(
                  id: s.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (c, s) => CollectionFormScreen(
                      id: s.pathParameters['id']),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/expenses',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: ExpensesScreen()),
          routes: [
            GoRoute(
              path: 'add',
              builder: (c, s) => const ExpenseFormScreen(),
            ),
            GoRoute(
              path: ':id/edit',
              builder: (c, s) => ExpenseFormScreen(
                  id: s.pathParameters['id']),
            ),
          ],
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: ReportsScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (c, s) =>
              const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),
  ],
);
