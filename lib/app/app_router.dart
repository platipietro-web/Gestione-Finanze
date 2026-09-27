import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n.dart';
import '../core/layout/breakpoints.dart';
import '../core/router/app_routes.dart';
import '../core/router/redirect.dart';
import '../core/time/year_month.dart';
import '../features/assets/presentation/assets_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/history/presentation/snapshot_detail_screen.dart';
import '../features/investments/presentation/investments_screen.dart';
import '../features/monthly_update/presentation/update_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../shared/providers/session_providers.dart';
import '../shared/widgets/feedback_views.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Router unico dell'app. Non viene ricreato quando cambia la sessione:
/// la sessione aggiorna solo [refreshListenable] e il redirect si rivaluta.
final routerProvider = Provider<GoRouter>((ref) {
  final status = ValueNotifier<SessionStatus>(ref.read(sessionStatusProvider));
  ref.listen(sessionStatusProvider, (_, next) => status.value = next);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    refreshListenable: status,
    redirect: (context, state) =>
        resolveRedirect(status: status.value, uri: state.uri),
    errorBuilder: (context, state) => const _NotFoundScreen(),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.update,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: UpdateScreen(
            initialMonth: YearMonth.tryParse(state.uri.queryParameters['mese']),
          ),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.assets,
                builder: (context, state) => const AssetsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.investments,
                builder: (context, state) => const InvestmentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      // Su schermi larghi elenco e dettaglio sono affiancati.
                      return context.windowSize.isWide
                          ? NoTransitionPage(
                              key: state.pageKey,
                              child: HistoryScreen(selectedId: id),
                            )
                          : MaterialPage(
                              key: state.pageKey,
                              child: SnapshotDetailScreen(snapshotId: id),
                            );
                    },
                    routes: [
                      GoRoute(
                        path: 'modifica',
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) => MaterialPage(
                          fullscreenDialog: true,
                          child: UpdateScreen(
                            snapshotId: state.pathParameters['id'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    status.dispose();
  });
  return router;
});

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: EmptyState(
        icon: Icons.explore_off_outlined,
        title: l10n.pageNotFound,
        actionLabel: l10n.goHome,
        actionIcon: Icons.home_outlined,
        onAction: () => context.go(AppRoutes.dashboard),
      ),
    );
  }
}
