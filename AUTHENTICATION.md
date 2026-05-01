# 📱 ITM LA VISION - Système d'Authentification

## ✅ SYSTÈME DE LOGIN COMPLÈTEMENT IMPLÉMENTÉ

### 🎯 Objectif
Application mobile Flutter permettant aux parents de suivre la scolarité de leurs enfants via une API Laravel sécurisée.

---

## 🏗️ ARCHITECTURE IMPLÉMENTÉE

### 1️⃣ **Couche Domaine** (`domain/`)
**Responsabilité:** Définir les modèles métier

```
domain/models/
├── user.dart              ✅ Modèle utilisateur
└── login_response.dart    ✅ Réponse API login
```

**Caractéristiques:**
- Sérialisation JSON complète
- Immutabilité avec `copyWith()`
- Types fortement typés

---

### 2️⃣ **Couche Services** (`core/services/`)
**Responsabilité:** Gérer les I/O (réseau, stockage)

```
core/services/
├── api_service.dart           ✅ Client HTTP Dio
└── local_storage_service.dart ✅ Stockage Hive
```

**API Service:**
- Gestion automatique des tokens Bearer
- Intercepteurs pour logs
- Gestion d'erreurs Dio complète
- Endpoints: `/auth/login`, `/auth/logout`, `/auth/refresh`

**Local Storage Service:**
- Persistence des tokens et user data
- Cache avec Hive
- Clear/reset complet

---

### 3️⃣ **Couche Repository** (`data/repositories/`)
**Responsabilité:** Logique métier et coordination services

```
data/repositories/
└── auth_repository.dart ✅ Repository authentification
```

**Méthodes principales:**
```dart
login(email, password)      // Authentification
logout()                     // Déconnexion
isAuthenticated()           // Vérifier l'état
getCurrentUser()            // Récupérer user actuel
initializeAuth()            // Init au démarrage
refreshToken()              // Rafraîchir token
```

---

### 4️⃣ **Couche Présentation - ViewModels** (`presentation/viewmodels/`)
**Responsabilité:** Gestion d'état Riverpod

```
presentation/viewmodels/
├── auth_viewmodel.dart      ✅ Gestion auth (NotifierProvider)
└── navigation_viewmodel.dart ✅ Gestion navigation
```

**Auth State Machine:**
```
AuthStateInitial      → État initial (non connecté)
         ↓
AuthStateLoading      → Pendant la requête login
    ↙        ↘
Success      Error
   ↓           ↓
Authenticated → AuthStateError
```

**Providers Riverpod:**
- `apiServiceProvider` - Service HTTP singleton
- `localStorageServiceProvider` - Stockage local singleton
- `authRepositoryProvider` - Repository singleton
- `authStateProvider` - État auth (NotifierProvider)
- `navigationProvider` - Index de navigation

---

### 5️⃣ **Couche Présentation - Screens** (`presentation/views/`)
**Responsabilité:** Interface utilisateur

```
presentation/views/
├── splash_screen.dart           ✅ Écran de démarrage
├── login_screen.dart            ✅ Formulaire connexion
├── home_screen.dart             ✅ Accueil
├── profile_screen.dart          ✅ Profil utilisateur
└── main_navigation_screen.dart  ✅ Navigation principale
```

**Splash Screen:**
- Logo ITM LA VISION
- Initialisation auth automatique
- Redirection basée sur l'authentification
- Duration: 2 secondes

**Login Screen:**
- Champs email et password
- Validation d'inputs
- Affichage/masquage password
- Gestion des erreurs
- Loading state
- Liens "Aide", "Oublié?", "Conditions"

---

### 6️⃣ **Routage** (`core/routes/`)
**Responsabilité:** Navigation entre screens

```
core/routes/
└── app_router.dart ✅ GoRouter configuration
```

**Routes définies:**
```
/splash  → SplashScreen
/login   → LoginScreen
/home    → MainNavigationScreen
  └── /home/profile → ProfileScreen
```

**Redirects automatiques:**
- Non authentifié → `/login`
- Authentifié + sur `/login` → `/home`
- Au démarrage → `/splash`

---

### 7️⃣ **Configuration** (`config/`)
**Responsabilité:** Constantes et configuration

```
config/
├── constants.dart      ✅ URLs, clés, etc.
└── themes/
    ├── app_colors.dart ✅ Palette couleurs
    └── app_theme.dart  ✅ Thème Material
```

**Couleurs:**
- Primary: `#1e3a8a` (Bleu foncé)
- Accent: `#f44336` (Rouge)
- Success: `#4CAF50`
- Warning: `#FFC107`

---

## 🔄 FLUX D'AUTHENTIFICATION COMPLET

```
┌─────────────────────────────────────────────────┐
│ 1. App Démarrage                                │
│    └─> main() → ProviderScope → MaterialApp    │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ 2. GoRouter Initialisation                      │
│    └─> Vérifie authState                        │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ 3. SplashScreen Affichage (2s)                  │
│    ├─> Image logo + tagline                     │
│    ├─> Loading indicator                        │
│    └─> AuthNotifier.initializeAuth()            │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ 4. Token Restoration                            │
│    ├─> localStorage.getToken()                  │
│    ├─> apiService.setAuthToken()                │
│    └─> state = AuthState.authenticated(user)    │
└──────────────────┬──────────────────────────────┘
                   ↓
        ┌──────────┴──────────┐
        ↓                     ↓
   Token ✅              Token ❌
        ↓                     ↓
   /home                  /login
```

---

## 🔐 SÉCURITÉ IMPLÉMENTÉE

✅ **Authentification:**
- Tokens Bearer (Sanctum/Passport)
- Refresh token automatique
- Secure storage avec Hive

✅ **Validation:**
- Email validation côté client
- Password minimum 6 caractères
- Input sanitization

✅ **Error Handling:**
- Gestion Dio errors complète
- Messages utilisateur clairs
- Logging sécurisé

---

## 📡 ENDPOINTS API UTILISÉS

```http
POST /api/auth/login
  Request:  { email: string, password: string }
  Response: { 
    success: bool,
    message: string,
    data: {
      user: { id, name, email, role, phone, avatar, is_active, last_login_at },
      token: string,
      token_type: "Bearer"
    }
  }

POST /api/auth/logout
  Header: Authorization: Bearer {token}
  Response: { success: bool, message: string }

POST /api/auth/refresh
  Header: Authorization: Bearer {token}
  Response: { data: { token: string, token_type: "Bearer" } }
```

---

## 🧪 DÉPENDANCES UTILISÉES

```yaml
dependencies:
  flutter_riverpod: ^3.3.1        # State management
  go_router: ^17.2.0              # Navigation
  dio: ^5.9.2                     # HTTP client
  hive_flutter: ^1.1.0            # Local storage
  connectivity_plus: ^7.1.1       # Network detection
  share_plus: ^12.0.2             # Share files
  url_launcher: ^6.3.2            # Open URLs
```

---

## 🚀 DÉPLOIEMENT

### Android
```bash
flutter build apk --release
# APK généré: build/app/outputs/flutter-app.apk
```

### iOS
```bash
flutter build ios --release
# Prêt pour TestFlight/App Store
```

---

## 📝 ÉTAPES SUIVANTES

Maintenant que le Login est complet, implémenter:

1. **Module Gestion des Enfants** - Récupérer les enfants du parent
2. **Module Notes & Bulletins** - Suivi académique
3. **Module Assiduité** - Absences et retards
4. **Module Financier** - Paiements et frais
5. **Module Messagerie** - Communication parent-enseignant
6. **Notifications Push** - Firebase FCM

---

## ✅ CHECKLIST VALIDATIONS

- [x] Modèles User et LoginResponse
- [x] API Service avec gestion tokens
- [x] Local Storage avec Hive
- [x] Auth Repository
- [x] Riverpod Notifiers (auth + navigation)
- [x] Sealed classes pour type-safety
- [x] Splash Screen avec logo
- [x] Login Screen complet
- [x] GoRouter avec redirects
- [x] Thème et couleurs
- [x] Analyse Dart 0 erreurs
- [x] Documentation complète

---

**Auteur:** GitHub Copilot  
**Date:** 11 Avril 2026  
**Version App:** 1.0.0

