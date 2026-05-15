class AppConstants {

  // Storage Keys (Hive)
  static const String settingsBoxName = 'settings';
  static const String onboardingBoxName = 'onboarding';
  static const String authBoxName = 'auth';

  // Settings Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // UI Constants
  static const double largeTouchTarget = 56.0;
  static const double buttonBorderRadius = 16.0;
  static const double cardBorderRadius = 20.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // App Info
  static const String appName = 'Vision';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A mobile application for parents to handle their children.';
  static const String appLogoPath = 'assets/images/logo.png';
  static const String noInternetImagePath = 'assets/images/no-internet-connection.png';
  
  // Onboarding Images
  static const String onboardingImage1 = 'assets/images/onBoarding.png';
  static const String onboardingImage2 = 'assets/images/picture.png';
  static const String onboardingImage3 = 'assets/images/logo.png';

  // Onboarding Lottie Assets


  // API Base URLs
  // NOTE: Remplacez par l'adresse IP locale du serveur si sur le même réseau
  // Ex: static const String apiBaseUrl = 'http://192.168.1.100:8000/api/v1';
  // Ou par l'adresse IP externe si le serveur est accessible publiquement
  static const String apiBaseUrl = 'https://itmlavision.net/api/v1';

  // Storage base URL — utilisé pour les images/fichiers (sans /api/v1)
  static const String storageBaseUrl = 'http://158.220.102.41:9000/itm-school';

}