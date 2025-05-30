import 'package:flutter/material.dart';

enum Flavor {
  user,
  admin,
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final ThemeData theme;
  final String baseUrl;

  static FlavorConfig? _instance;

  factory FlavorConfig({
    required Flavor flavor,
    required String name,
    required Color primaryColor,
    required Color secondaryColor,
    required ThemeData theme,
    required String baseUrl,
  }) {
    _instance ??= FlavorConfig._internal(
      flavor: flavor,
      name: name,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      theme: theme,
      baseUrl: baseUrl,
    );
    return _instance!;
  }

  FlavorConfig._internal({
    required this.flavor,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.theme,
    required this.baseUrl,
  });

  static FlavorConfig get instance {
    if (_instance == null) {
      throw Exception("FlavorConfig not initialized");
    }
    return _instance!;
  }

  static bool isUser() => _instance!.flavor == Flavor.user;
  static bool isAdmin() => _instance!.flavor == Flavor.admin;
} 