/// Appwrite Configuration
///
/// Configuration loaded from environment variables with fallback defaults.
///
/// To configure for different environments:
///
/// 1. Via dart-define flags:
///    flutter run --dart-define=APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1 \
///                --dart-define=APPWRITE_PROJECT_ID=your-project-id \
///                --dart-define=APPWRITE_DATABASE_ID=your-database-id \
///                --dart-define=APPWRITE_COLLECTION_ID=your-collection-id
///
/// 2. Via build command:
///    flutter build web --dart-define=APPWRITE_PROJECT_ID=prod-project-id
///
/// 3. Using .env file with build_runner (recommended for local dev)
class AppConfig {
  // Appwrite Endpoint - your Appwrite server URL
  static const String appwriteEndpoint = String.fromEnvironment(
    'APPWRITE_ENDPOINT',
    defaultValue: 'https://cloud.appwrite.io/v1',
  );

  // Your Appwrite Project ID
  static const String appwriteProjectId = String.fromEnvironment(
    'APPWRITE_PROJECT_ID',
    defaultValue: 'YOUR_PROJECT_ID',
  );

  // Database ID for CountDownNow
  static const String appwriteDatabaseId = String.fromEnvironment(
    'APPWRITE_DATABASE_ID',
    defaultValue: 'YOUR_DATABASE_ID',
  );

  // Collection ID for storing countdowns
  static const String appwriteCollectionIdCountdowns = String.fromEnvironment(
    'APPWRITE_COLLECTION_ID',
    defaultValue: 'YOUR_COLLECTION_ID',
  );

  /// Check if configuration is properly set up
  static bool get isConfigured {
    return appwriteProjectId != 'YOUR_PROJECT_ID' &&
        appwriteDatabaseId != 'YOUR_DATABASE_ID' &&
        appwriteCollectionIdCountdowns != 'YOUR_COLLECTION_ID';
  }

  /// Get configuration summary for debugging
  static String get configSummary {
    return '''
AppConfig:
  Endpoint: $appwriteEndpoint
  Project ID: ${appwriteProjectId == 'YOUR_PROJECT_ID' ? '⚠️ NOT SET' : appwriteProjectId}
  Database ID: ${appwriteDatabaseId == 'YOUR_DATABASE_ID' ? '⚠️ NOT SET' : appwriteDatabaseId}
  Collection ID: ${appwriteCollectionIdCountdowns == 'YOUR_COLLECTION_ID' ? '⚠️ NOT SET' : appwriteCollectionIdCountdowns}
  Configured: ${isConfigured ? '✅' : '❌'}
''';
  }
}
