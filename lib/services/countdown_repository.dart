import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_config.dart';
import '../models/countdown.dart';
import 'appwrite_client.dart';

/// Repository for Countdown CRUD operations
class CountdownRepository {
  final TablesDB _tablesDB;

  CountdownRepository(this._tablesDB);

  /// Get countdown by slug
  Future<Countdown?> getBySlug(String slug) async {
    try {
      final response = await _tablesDB.listRows(
        databaseId: AppConfig.appwriteDatabaseId,
        tableId: AppConfig.appwriteCollectionIdCountdowns,
        queries: [Query.equal('slug', slug), Query.limit(1)],
      );

      if (response.rows.isEmpty) {
        return null;
      }

      return Countdown.fromMap(response.rows.first.data);
    } on AppwriteException {
      // Silently return null if not found
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all countdowns by owner
  Future<List<Countdown>> getByOwner(String ownerId) async {
    try {
      final response = await _tablesDB.listRows(
        databaseId: AppConfig.appwriteDatabaseId,
        tableId: AppConfig.appwriteCollectionIdCountdowns,
        queries: [
          Query.equal('ownerId', ownerId),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return response.rows
          .map((doc) => Countdown.fromMap(doc.data))
          .toList();
    } on AppwriteException {
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new countdown
  Future<Countdown> create(Countdown countdown) async {
    try {
      final response = await _tablesDB.createRow(
        databaseId: AppConfig.appwriteDatabaseId,
        tableId: AppConfig.appwriteCollectionIdCountdowns,
        rowId: ID.unique(),
        data: countdown.toMap(),
      );

      return Countdown.fromMap(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing countdown
  Future<Countdown> update(Countdown countdown) async {
    try {
      if (countdown.id == null) {
        throw Exception('Cannot update countdown without an ID');
      }

      final response = await _tablesDB.updateRow(
        databaseId: AppConfig.appwriteDatabaseId,
        tableId: AppConfig.appwriteCollectionIdCountdowns,
        rowId: countdown.id!,
        data: countdown.toMap(),
      );

      return Countdown.fromMap(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a countdown
  Future<void> delete(String id) async {
    try {
      await _tablesDB.deleteRow(
        databaseId: AppConfig.appwriteDatabaseId,
        tableId: AppConfig.appwriteCollectionIdCountdowns,
        rowId: id,
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider for CountdownRepository
final countdownRepositoryProvider = Provider<CountdownRepository>((ref) {
  final tablesDB = ref.watch(tablesDBProvider);
  return CountdownRepository(tablesDB);
});

/// In-memory storage for anonymous countdowns
class InMemoryCountdownStore extends Notifier<List<Countdown>> {
  @override
  List<Countdown> build() {
    return [];
  }

  void add(Countdown countdown) {
    state = [...state, countdown];
  }

  Countdown? getBySlug(String slug) {
    try {
      return state.firstWhere((c) => c.slug == slug);
    } catch (e) {
      return null;
    }
  }

  void remove(String slug) {
    state = state.where((c) => c.slug != slug).toList();
  }

  void clear() {
    state = [];
  }
}

/// Provider for in-memory countdown store
final inMemoryCountdownStoreProvider =
    NotifierProvider<InMemoryCountdownStore, List<Countdown>>(() {
      return InMemoryCountdownStore();
    });
