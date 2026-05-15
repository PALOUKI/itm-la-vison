import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vision/core/services/local_storage_service.dart';
import 'package:vision/presentation/views/help_screen.dart';
import 'package:vision/presentation/views/legal_document_screen.dart';
import 'package:vision/presentation/views/login_screen.dart';
import 'package:vision/presentation/views/onboarding_screen.dart';
import 'package:vision/presentation/views/profile_screen.dart';
import 'package:vision/presentation/views/splash_screen.dart';
import 'package:vision/presentation/views/child_detail_screen.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';
import 'package:vision/presentation/views/main_navigation_screen.dart';
import 'package:vision/presentation/views/finances_screen.dart';
import 'package:vision/presentation/views/messages_screen.dart';
import 'package:vision/presentation/views/attendances_screen.dart';
import 'package:vision/presentation/views/timetable_screen.dart';
import 'package:vision/presentation/views/grades_screen.dart';
import 'package:vision/presentation/views/bulletins_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  late final GoRouter router;

  router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final storage = ref.read(localStorageServiceProvider);
      
      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isLogin = state.matchedLocation == '/login';
      final isPublicRoute = {
        '/login',
        '/onboarding',
        '/help',
        '/terms',
        '/privacy',
      }.contains(state.matchedLocation);

      // 1. PHASE DE CHARGEMENT
      if (authState is AuthStateLoading) {
        return isSplash ? null : null;
      }

      // 2. VÉRIFICATION ONBOARDING (Seulement si on vient du splash ou si on essaie d'y accéder)
      final hasDoneOnboarding = storage.hasCompletedOnboarding();
      if (!hasDoneOnboarding) {
        if (isOnboarding) return null;
        return '/onboarding';
      }

      // Si l'utilisateur a fini l'onboarding mais essaie d'y retourner
      if (isOnboarding && hasDoneOnboarding) {
        return authState.isAuthenticated ? '/home' : '/login';
      }

      // 3. CAS AUTHENTIFIÉ
      if (authState.isAuthenticated) {
        if (isSplash || isLogin || isOnboarding) return '/home';
        return null;
      }

      // 4. CAS NON AUTHENTIFIÉ
      if (isSplash) return '/login';
      if (!isPublicRoute) return '/login';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => LegalDocumentScreen.terms(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => LegalDocumentScreen.privacy(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'child-detail/:uuid',
            builder: (context, state) {
              final uuid = state.pathParameters['uuid']!;
              return ChildDetailScreen(childUuid: uuid);
            },
            routes: [
              GoRoute(
                path: 'finances',
                builder: (context, state) {
                  final uuid = state.pathParameters['uuid']!;
                  return FinancesScreen(childUuid: uuid);
                },
              ),
              GoRoute(
                path: 'messages',
                builder: (context, state) {
                  final uuid = state.pathParameters['uuid']!;
                  return MessagesScreen(childUuid: uuid);
                },
              ),
              GoRoute(
                path: 'attendances',
                builder: (context, state) {
                  final uuid = state.pathParameters['uuid']!;
                  return AttendancesScreen(childUuid: uuid);
                },
              ),
              GoRoute(
                path: 'timetable',
                builder: (context, state) {
                  final uuid = state.pathParameters['uuid']!;
                  return TimetableScreen(childUuid: uuid);
                },
              ),
              GoRoute(
                path: 'grades',
                builder: (context, state) {
                  final uuid = state.pathParameters['uuid']!;
                  final child = state.extra as dynamic;
                  return GradesScreen(childUuid: uuid, child: child);
                },
              ),
              GoRoute(
                path: 'bulletins',
                builder: (context, state) {
                  final uuid = state.pathParameters['uuid']!;
                  final child = state.extra as dynamic;
                  return BulletinsScreen(childUuid: uuid, child: child);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.listen<AuthState>(authStateProvider, (_, __) {
    router.refresh();
  });

  return router;
});
