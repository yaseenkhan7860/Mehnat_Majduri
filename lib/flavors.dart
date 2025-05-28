enum Flavor {
  user,
  instructor,
  admin,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.user:
        return 'User App';
      case Flavor.instructor:
        return 'Instructor App';
      case Flavor.admin:
        return 'Admin App';
    }
  }

}
