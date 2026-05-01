import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vision/presentation/views/login_screen.dart';
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
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';

      // 1. PHASE DE CHARGEMENT : 
      // Si on est sur le splash screen et que ça charge, on y reste.
      // Si on est ailleurs (ex: login) et que ça passe en loading, on ne force PAS le splash.
      if (authState is AuthStateLoading) {
        return isSplash ? null : null;
      }

      // 2. CAS AUTHENTIFIÉ
      if (authState.isAuthenticated) {
        // Rediriger vers home si on vient du splash ou du login
        if (isSplash || isLogin) return '/home';
        // Sinon, laisser l'utilisateur où il est
        return null;
      }

      // 3. CAS NON AUTHENTIFIÉ (Initial, Error)
      // Si on est sur splash, on DOIT aller au login car le check est fini
      if (isSplash) return '/login';

      // Si on n'est pas authentifié et qu'on n'est pas sur login, on force login
      // (Cela protège toutes les routes /home et sous-routes)
      if (!isLogin) return '/login';

      // Si on est sur login, on y reste
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
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
});
