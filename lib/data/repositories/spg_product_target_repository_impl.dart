import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/spg_product_target_model.dart';
import '../../domain/entities/spg_product_target_entity.dart';
import '../../domain/repositories/spg_product_target_repository.dart';
import '../../../core/error/exceptions.dart';

class SpgProductTargetRepositoryImpl implements SpgProductTargetRepository {
  final DatabaseHelper dbHelper;

  SpgProductTargetRepositoryImpl({required this.dbHelper});

  @override
  Future<List<SpgProductTargetEntity>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final maps = await db.query(
        'spg_product_targets',
        where: 'event_id = ?',
        whereArgs: [eventId],
        orderBy: 'spg_id ASC, product_id ASC',
      );
      return maps.map((map) => SpgProductTargetModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil target: $e');
    }
  }

  @override
  Future<List<SpgProductTargetEntity>> getByEventSpg(String eventId, String spgId) async {
    try {
      final db = await dbHelper.database;
      final maps = await db.query(
        'spg_product_targets',
        where: 'event_id = ? AND spg_id = ?',
        whereArgs: [eventId, spgId],
        orderBy: 'product_id ASC',
      );
      return maps.map((map) => SpgProductTargetModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil target SPG: $e');
    }
  }

  @override
  Future<SpgProductTargetEntity?> getByEventSpgProduct(String eventId, String spgId, String productId) async {
    try {
      final db = await dbHelper.database;
      final maps = await db.query(
        'spg_product_targets',
        where: 'event_id = ? AND spg_id = ? AND product_id = ?',
        whereArgs: [eventId, spgId, productId],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return SpgProductTargetModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil target: $e');
    }
  }

  @override
  Future<SpgProductTargetEntity> create(SpgProductTargetEntity target) async {
    try {
      final db = await dbHelper.database;
      final now = DateTime.now();
      final model = SpgProductTargetModel(
        id: target.id.isEmpty ? const Uuid().v4() : target.id,
        eventId: target.eventId,
        spgId: target.spgId,
        productId: target.productId,
        targetQty: target.targetQty,
        createdAt: now,
        updatedAt: now,
      );
      await db.insert('spg_product_targets', model.toMap());
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal membuat target: $e');
    }
  }

  @override
  Future<SpgProductTargetEntity> update(SpgProductTargetEntity target) async {
    try {
      final db = await dbHelper.database;
      final existingMaps = await db.query(
        'spg_product_targets',
        where: 'id = ?',
        whereArgs: [target.id],
        limit: 1,
      );
      
      final existingCreatedAt = existingMaps.isNotEmpty
          ? DatabaseHelper.stringToDateTime(existingMaps.first['created_at'] as String)
          : DateTime.now();

      final model = SpgProductTargetModel(
        id: target.id,
        eventId: target.eventId,
        spgId: target.spgId,
        productId: target.productId,
        targetQty: target.targetQty,
        createdAt: existingCreatedAt,
        updatedAt: DateTime.now(),
      );
      
      await db.update(
        'spg_product_targets',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [target.id],
      );
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal update target: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete('spg_product_targets', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal hapus target: $e');
    }
  }

  @override
  Future<void> bulkCreateOrUpdate(List<SpgProductTargetEntity> targets) async {
    try {
      final db = await dbHelper.database;
      final now = DateTime.now();
      await db.transaction((txn) async {
        for (final target in targets) {
          final existing = await txn.query(
            'spg_product_targets',
            where: 'event_id = ? AND spg_id = ? AND product_id = ?',
            whereArgs: [target.eventId, target.spgId, target.productId],
            limit: 1,
          );

          final model = SpgProductTargetModel(
            id: existing.isNotEmpty ? existing.first['id'] as String : const Uuid().v4(),
            eventId: target.eventId,
            spgId: target.spgId,
            productId: target.productId,
            targetQty: target.targetQty,
            createdAt: existing.isNotEmpty
                ? DatabaseHelper.stringToDateTime(existing.first['created_at'] as String)
                : now,
            updatedAt: now,
          );

          if (existing.isNotEmpty) {
            await txn.update(
              'spg_product_targets',
              model.toMap(),
              where: 'id = ?',
              whereArgs: [model.id],
            );
          } else {
            await txn.insert('spg_product_targets', model.toMap());
          }
        }
      });
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal bulk create/update target: $e');
    }
  }
}