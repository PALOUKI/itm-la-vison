# 🔍 GUIDE DE DÉBOGAGE - ITM LA VISION

## 🎯 Erreurs Courantes et Solutions

### ❌ "Connexion refusée" / "Connection refused"

**Cause:** Le serveur API n'est pas accessible

**Solutions:**
```bash
# 1. Vérifier la base URL dans constants.dart
lib/config/constants.dart → apiBaseUrl

# 2. Tester la connexion avec curl
curl -X POST http://161.97.110.189:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"nestor@gmail.com","password":"Nestor9j123"}'

# 3. Vérifier internet sur le device
# Aller à Settings → WiFi et vérifier la connexion

# 4. Vérifier le firewall (si sur PC)
# Autoriser Flutter à accéder au réseau
```

---

### ❌ "Failed to connect to the database"

**Cause:** Problème de connexion Laravel

**Solutions:**
```bash
# Sur le serveur Laravel:
php artisan migrate
php artisan db:seed
php artisan cache:clear
php artisan config:cache

# Vérifier le .env
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=vision_db
DB_USERNAME=root
DB_PASSWORD=password
```

---

### ❌ "Invalid token" après login

**Cause:** Token expiré ou format incorrect

**Solutions:**
```dart
// 1. Forcer un refresh token
await ref.read(authStateProvider.notifier).refreshToken();

// 2. Nettoyer le cache local
await ref.read(localStorageServiceProvider).clear();

// 3. Se reconnecter
await ref.read(authStateProvider.notifier).login(email, password);

// 4. Vérifier que Sanctum est bien configuré dans Laravel
// config/sanctum.php
// 'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', 'localhost')),
```

---

### ❌ "RenderFlex overflowed by X pixels"

**Cause:** Layout widget déborde de l'écran

**Solution:** 
```dart
// ✅ Bon - Utiliser Wrap ou Expanded
Wrap(
  alignment: WrapAlignment.center,
  children: [...],
)

// ❌ Mauvais - Row sans wrap
Row(
  children: [...],  // Déborde si trop de contenu
)
```

---

### ❌ "StateNotifierProvider isn't defined"

**Cause:** Version de Riverpod incompatible

**Solution:**
```yaml
# pubspec.yaml - Utiliser NotifierProvider à la place
flutter_riverpod: ^3.3.1  # ✅ Version 3.x

# ✅ Code correct avec Notifier
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);
```

---

### ❌ "The instance member can't be accessed on a class"

**Cause:** Accès incorrect aux providers Riverpod

**Solutions:**
```dart
// ❌ Mauvais
ref.authStateProvider  // Direct access - ERREUR

// ✅ Bon - Utiliser watch
final authState = ref.watch(authStateProvider);

// ✅ Bon - Utiliser read pour action
await ref.read(authStateProvider.notifier).login(email, pass);
```

---

## 🧪 TESTS MANUELS

### Test 1: Splash Screen
```
1. Lancer l'app
2. Écran noir 1-2 secondes
3. Logo + tagline affichés
4. Redirection automatique vers /login (si pas authentifié)
   ou /home (si authentifié)
```

### Test 2: Login Screen
```
1. Email vide → Erreur "Email is required"
2. Email invalide → Erreur "Please enter a valid email"
3. Password < 6 chars → Erreur "Password must be at least 6 characters"
4. Email + password valides → Spinner "Se Connecter"
5. Réponse 200 → Redirection /home
6. Réponse 401 → Erreur "Unauthorized"
```

### Test 3: Token Persistence
```
1. Login avec credentials
2. Fermer l'app
3. Relancer l'app
4. Directement sur /home (pas besoin de se reconnecter)
```

### Test 4: Logout
```
1. Aller à /home/profile
2. Cliquer "Déconnexion"
3. Token supprimé du stockage local
4. Redirection vers /login
```

### Test 5: Navigation
```
1. /splash → 2s → /login (si pas authentifié)
2. /login → login → /home
3. /home → bottom bar → /home/profile
4. /home/profile → déconnexion → /login
```

---

## 🔬 DEBUGGING AVANCÉ

### Activer les logs Dio
```dart
// api_service.dart - Déjà activé
_dio.interceptors.add(
  LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
    requestHeader: true,
  ),
);
```

### Logs Flutter
```bash
# Dans la console
flutter run -v  # Verbose mode
```

### Vérifier le stockage local (Hive)
```dart
// Dans main.dart pour debug
await LocalStorageService().initialize();
final token = LocalStorageService().getToken();
print('Token stored: $token');
```

### Vérifier l'état Riverpod
```dart
// Dans la console Flutter
print(ref.read(authStateProvider));  // Affiche l'état actuel
```

---

## 📊 ENDPOINT TESTING

### Tester l'endpoint Login

**curl:**
```bash
curl -X POST http://161.97.110.189:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "nestor@gmail.com",
    "password": "Nestor9j123"
  }'
```

**Postman:**
1. Method: POST
2. URL: http://161.97.110.189:8000/api/auth/login
3. Headers: Content-Type: application/json
4. Body (raw JSON):
```json
{
  "email": "nestor@gmail.com",
  "password": "Nestor9j123"
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "KPADJA Kokoussè Nestor",
      "email": "nestor@gmail.com",
      "role": "parent",
      "phone": "+228 97 48 58 15",
      "avatar": null,
      "is_active": true,
      "last_login_at": "2026-04-11T21:44:12.000000Z"
    },
    "token": "5|PRvdK3kCJaKZs3b8dQrQiTBYPdf2it4l7oqDk8Wy29dde4a3",
    "token_type": "Bearer"
  }
}
```

---

## 🔐 SECURITY CHECKLIST

- [ ] Tokens jamais affichés en logs (production)
- [ ] HTTPS uniquement (sauf localhost dev)
- [ ] Tokens expirent après inactivité
- [ ] Refresh token endpoint protégé
- [ ] Logout nettoie le stockage local
- [ ] Validation email/password côté client
- [ ] Messages d'erreur génériques (pas de détails sensibles)
- [ ] Pas de passwords en logs

---

## 🚀 PERFORMANCE TIPS

### Optimiser la taille du APK
```bash
flutter build apk --release --split-per-abi
# Génère APK séparés par architecture (plus petit)
```

### Optimiser les builds
```bash
flutter clean
flutter pub get
flutter pub upgrade --major-versions
flutter analyze
```

### Réduire les dépendances
```bash
flutter pub deps --json  # Voir les dépendances
flutter pub cache clean  # Nettoyer le cache
```

---

## 🐛 ISSUE REPORTING

Si vous trouvez un bug, fournissez:

1. **Platform:** Android / iOS
2. **Device:** Modèle du device
3. **Version:** Android 12 / iOS 15+
4. **Steps to reproduce:**
   - ...
5. **Expected behavior:**
   - ...
6. **Actual behavior:**
   - ...
7. **Logs:**
   ```
   flutter run -v output
   ```

---

## 📞 SUPPORT CHANNELS

- **Documentation:** `AUTHENTICATION.md`, `LOGIN_IMPLEMENTATION.md`
- **Issues:** GitHub Issues
- **Questions:** Slack/Discord channel

---

**Last Updated:** 11 Avril 2026  
**Version:** 1.0.0

