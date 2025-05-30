import 'package:astro/flavors.dart';

/// Helper class to resolve assets based on the current flavor
class AssetResolver {
  const AssetResolver._();

  /// Returns the path to an image asset based on the current flavor
  /// If the asset exists in the flavor-specific directory, that path is returned
  /// Otherwise, falls back to the common assets directory
  static String image(String imageName) {
    final flavor = F.appFlavor.name;
    return 'assets/images/$flavor/$imageName';
  }

  /// Returns the path to a common image asset (shared across all flavors)
  static String commonImage(String imageName) {
    return 'assets/images/$imageName';
  }

  /// Returns the logo path for the current flavor
  static String get logo {
    switch (F.appFlavor) {
      case Flavor.user:
        return 'assets/images/user/user_logo.png';
      case Flavor.admin:
        return 'assets/images/admin/admin_logo.png';
    }
  }

  /// Returns the splash image path for the current flavor
  static String get splash {
    switch (F.appFlavor) {
      case Flavor.user:
        return 'assets/images/user/splash.png';
      case Flavor.admin:
        return 'assets/images/admin/splash.png';
    }
  }
} 