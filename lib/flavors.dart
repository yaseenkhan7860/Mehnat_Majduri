enum Flavor {
  user,    // For regular user app
  admin,   // For admin app
  instructor, // For instructor app
}

class F {
  static late Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.admin: 
        return "Astro Admin";
      case Flavor.user: 
        return "Astro";
      case Flavor.instructor:
        return "Astro Instructor";
    }
  }

  static bool get isAdminApp => appFlavor == Flavor.admin;
  static bool get isInstructorApp => appFlavor == Flavor.instructor;
}
