import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_config.dart';

/// Appwrite Client Service
/// Singleton pattern for Appwrite SDK initialization
class AppwriteClientService {
  static final AppwriteClientService _instance =
      AppwriteClientService._internal();
  factory AppwriteClientService() => _instance;
  AppwriteClientService._internal();

  late Client _client;
  late Account _account;
  late Databases _databases;
  late TablesDB _tablesDB;

  /// Initialize Appwrite SDK
  void initialize() {
    _client = Client()
        .setEndpoint(AppConfig.appwriteEndpoint)
        .setProject(AppConfig.appwriteProjectId)
        .setSelfSigned(status: true); // For development with self-signed certs

    _account = Account(_client);
    _databases = Databases(_client);
    _tablesDB = TablesDB(_client);
  }

  Client get client => _client;
  Account get account => _account;
  Databases get databases => _databases;
  TablesDB get tablesDB => _tablesDB;
}

/// Provider for Appwrite Client
final appwriteClientProvider = Provider<AppwriteClientService>((ref) {
  final service = AppwriteClientService();
  service.initialize();
  return service;
});

/// Provider for Account
final accountProvider = Provider<Account>((ref) {
  return ref.watch(appwriteClientProvider).account;
});

/// Provider for Databases
final databasesProvider = Provider<Databases>((ref) {
  return ref.watch(appwriteClientProvider).databases;
});

final tablesDBProvider = Provider<TablesDB>((ref) {
  return ref.watch(appwriteClientProvider).tablesDB;
});