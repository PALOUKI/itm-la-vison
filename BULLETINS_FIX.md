# Correction de la Gestion des Bulletins

## Problème Identifié
Lorsqu'un bulletin n'était pas encore disponible, l'API retournait un code HTTP 403 avec le message:
```json
{"success":false,"message":"Bulletin access not enabled"}
```

Cependant, l'application affichait un `CircularProgressIndicator` qui tournait indéfiniment, car:
1. Les requêtes se relançaient plusieurs fois
2. Les erreurs n'étaient pas cachées, ce qui causait des appels API répétés
3. Le message d'erreur n'était pas amical pour l'utilisateur

## Solutions Implémentées

### 1. **Amélioration de la Gestion des Erreurs HTTP (api_service.dart)**

#### Méthode `getBulletinHtml()`
- Ajout d'une capture spécifique pour les erreurs HTTP 403
- Extraction du message d'erreur directement de la réponse API
- Lancer une exception avec le message approprié au lieu de laisser Dio gérer l'erreur

```dart
on DioException catch (e) {
  // Handle 403 Forbidden error (bulletin access not enabled)
  if (e.response?.statusCode == 403) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      throw Exception(data['message'] ?? 'Bulletin access not enabled');
    }
    throw Exception('Bulletin access not enabled');
  }
  throw _handleDioException(e);
}
```

#### Méthode `getMiniBulletinHtml()`
- Même amélioration pour les mini-bulletins (compositions)

### 2. **Cache des Requêtes (bulletins_viewmodel.dart)**

Ajout du modificateur `.withCache()` aux FutureProviders:

```dart
final bulletinHtmlProvider =
    FutureProvider.family<String, ({String studentUuid, int periodId})>(...).withCache(
      duration: const Duration(hours: 1)
    );

final miniBulletinHtmlProvider =
    FutureProvider.family<String, ({String studentUuid, int examId})>(...).withCache(
      duration: const Duration(hours: 1)
    );
```

**Effet:** Les erreurs et les succès sont cachés pendant 1 heure, évitant les requêtes répétées.

### 3. **Messages d'Erreur Amicaux (bulletins_screen.dart)**

Création d'une méthode `_buildErrorMessage()` qui affiche des messages spécifiques:

- **"Bulletin access not enabled"**: 
  - Icône: `lock_clock_outlined` (orange)
  - Message: "Le bulletin n'est pas encore disponible - Cet accès sera activé dès que les bulletins seront publié par l'établissement."
  - Pas de bouton "Réessayer" (l'utilisateur ne peut rien faire)

- **"Mini-bulletin access not enabled"**:
  - Icône: `lock_clock_outlined` (orange)
  - Message: "Les compositions ne sont pas encore disponibles - Ces documents seront accessibles une fois publié par l'établissement."
  - Pas de bouton "Réessayer"

- **Autres erreurs**: Messages adaptés (connexion, fichier non trouvé, etc.)

### 4. **Nettoyage du Code**

- Suppression des imports inutilisés
- Suppression de la variable `_webViewController` non utilisée
- Suppression de la méthode `_initializeWebViewController()`
- Utilisation de `.withValues()` au lieu de `.withOpacity()` (API moderne de Flutter)

## Résultat

✅ **Avant**: Spinner qui tourne indéfiniment + requêtes répétées
✅ **Après**: 
- Message amical immédiatement après que l'erreur soit reçue
- Les requêtes ne se relancent pas pendant 1 heure
- L'utilisateur comprend que c'est normal et qu'il faut attendre
- Meilleure expérience utilisateur

## Tests Manuels

1. Aller à l'écran "Bulletins"
2. Sélectionner une période où les bulletins ne sont pas disponibles
3. ✅ Vérifier que le message d'erreur s'affiche rapidement (< 2 secondes)
4. ✅ Vérifier que le spinner ne tourne pas indéfiniment
5. ✅ Vérifier que le bouton "Réessayer" n'apparaît pas pour "access not enabled"

## Fichiers Modifiés

1. `/lib/core/services/api_service.dart`
   - `getBulletinHtml()`: Gestion du code 403
   - `getMiniBulletinHtml()`: Gestion du code 403

2. `/lib/presentation/viewmodels/bulletins_viewmodel.dart`
   - Ajout du cache aux providers

3. `/lib/presentation/views/bulletins_screen.dart`
   - Amélioration de `_buildErrorMessage()`
   - Nettoyage des imports inutilisés
   - Suppression des variables inutilisées

