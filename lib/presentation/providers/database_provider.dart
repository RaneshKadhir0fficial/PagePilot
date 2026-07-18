import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pagepilot/data/database/app_database.dart';

/// Global database provider — single instance across the app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
