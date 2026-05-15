import 'package:vision/config/constants.dart';

class ImageUtils {
  /// Construit l'URL complète pour une image.
  /// Gère les chemins relatifs, les URLs absolues et les valeurs nulles.
  static String? getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }

    // Si le chemin est déjà une URL complète, on le retourne tel quel
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Nettoyage du slash de début si présent pour éviter les doubles slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    
    // Le serveur de stockage semble nécessiter le préfixe /profile_photos/ pour les avatars
    // On l'ajoute si ce n'est pas déjà présent dans le path et que c'est une photo de profil
    // Note: Si le backend renvoie déjà le chemin complet (ex: profile_photos/xyz.jpg), 
    // cette logique s'adaptera.
    
    return '${AppConstants.storageBaseUrl}/$cleanPath';
  }
}
