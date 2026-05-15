import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vision/core/routes/app_router.dart';
import 'package:vision/core/services/notification_service.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Erreur lors de l\'initialisation de Firebase: $e');
  }

  await initializeDateFormatting('fr_FR', null);
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialiser le service de notifications au démarrage (pour les jetons existants)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    // ÉCOUTER l'état d'authentification pour ré-initialiser les notifications après login
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthStateAuthenticated) {
        // L'utilisateur vient de se connecter ou son auth est confirmée
        debugPrint('Authentification confirmée, (ré)initialisation des notifications...');
        ref.read(notificationServiceProvider).initialize();
      }
    });

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp.router(
          title: 'ITM LA VISION',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1e3a8a)),
            fontFamily: 'Poppins',
          ),
          routerConfig: router,
        );
      },
    );
  }
}
