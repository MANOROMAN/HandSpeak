enum Environment {
  dev,
  staging,
  prod;

  bool get isDev => this == Environment.dev;
  bool get isStaging => this == Environment.staging;
  bool get isProd => this == Environment.prod;
}

class EnvironmentConfig {
  static Environment environment = Environment.dev;

  static String get apiBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://localhost:8080';
      case Environment.staging:
        return 'https://staging-api.handspeak.com';
      case Environment.prod:
        return 'https://api.handspeak.com';
    }
  }

  static String get wsBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'ws://localhost:8080';
      case Environment.staging:
        return 'wss://staging-api.handspeak.com';
      case Environment.prod:
        return 'wss://api.handspeak.com';
    }
  }

  static bool get enableLogging {
    switch (environment) {
      case Environment.dev:
      case Environment.staging:
        return true;
      case Environment.prod:
        return false;
    }
  }

  static bool get useMockData {
    switch (environment) {
      case Environment.dev:
        return true;
      case Environment.staging:
      case Environment.prod:
        return false;
    }
  }

  static Duration get timeoutDuration {
    switch (environment) {
      case Environment.dev:
        return const Duration(seconds: 30);
      case Environment.staging:
        return const Duration(seconds: 45);
      case Environment.prod:
        return const Duration(seconds: 60);
    }
  }

  static int get maxRetryAttempts {
    switch (environment) {
      case Environment.dev:
        return 1;
      case Environment.staging:
        return 2;
      case Environment.prod:
        return 3;
    }
  }

  static bool get enableCrashlytics {
    switch (environment) {
      case Environment.dev:
        return false;
      case Environment.staging:
      case Environment.prod:
        return true;
    }
  }

  static bool get enablePerformanceMonitoring {
    switch (environment) {
      case Environment.dev:
      case Environment.staging:
        return false;
      case Environment.prod:
        return true;
    }
  }
}
