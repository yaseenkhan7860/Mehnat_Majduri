enum Flavor {
  user,
  admin,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.user:
        return 'Astro';
      case Flavor.admin:
        return 'Astro Admin';
    }
  }

}
