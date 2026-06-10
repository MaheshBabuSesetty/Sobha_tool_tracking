enum AppFlavor { dev, uat, prod }

extension AppFlavorExtension on AppFlavor {
  String get name {
    switch (this) {
      case AppFlavor.dev:
        return 'DEV';
      case AppFlavor.uat:
        return 'UAT';
      case AppFlavor.prod:
        return 'PROD';
    }
  }

  String get envFile {
    switch (this) {
      case AppFlavor.dev:
        return '.env.dev';
      case AppFlavor.uat:
        return '.env.uat';
      case AppFlavor.prod:
        return '.env.prod';
    }
  }

  bool get isProduction => this == AppFlavor.prod;
  bool get isDev => this == AppFlavor.dev;
  bool get isUat => this == AppFlavor.uat;
}
