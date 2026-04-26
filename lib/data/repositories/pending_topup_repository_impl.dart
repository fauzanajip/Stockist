import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/pending_topup_model.dart';
import '../../domain/entities/pending_topup_entity.dart';
import '../../domain/repositories/pending_topup_repository.dart';
import '../../../core/error/exceptions.dart';

class PendingTopupRepositoryImpl implements PendingTopupRepository {
  final DatabaseHelper dbHelper;

  PendingTopupRepositoryImpl({required this.dbHelper});

  @override
  Future<List<PendingTopupEntity>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pending_topups',
        where: 'event_id = ?',
        whereArgs: [eventId],
        orderBy: 'created_at DESC',
      );
      return maps
          .map<PendingTopupEntity>((map) => PendingTopupModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to get pending topups: $e');
    }
  }

  @override
  Future<List<PendingTopupEntity>> getByEventAndSpb(String eventId, String? spbId) async {
    try {
      final db = await dbHelper.database;
      List<Map<String, dynamic>> maps;
      
      if (spbId == null) {
        maps = await db.query(
          'pending_topups',
          where: 'event_id = ?',
          whereArgs: [eventId],
          orderBy: 'created_at DESC',
        );
      } else {
        maps = await db.query(
          'pending_topups',
          where: 'event_id = ? AND spb_id = ?',
          whereArgs: [eventId, spbId],
          orderBy: 'created_at DESC',
        );
      }
      
      return maps
          .map<PendingTopupEntity>((map) => PendingTopupModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to get pending topups by SPB: $e');
    }
  }

  @override
  Future<PendingTopupEntity?> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'pending_topups',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return PendingTopupModel.fromMap(maps.first).toEntity();
      }
      return null;
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to get pending topup: $e');
    }
  }

  @override
  Future<PendingTopupEntity> create(PendingTopupEntity entity) async {
    try {
      final db = await dbHelper.database;
      final model = PendingTopupModel.fromEntity(entity);
      final id = entity.id.isEmpty ? const Uuid().v4() : entity.id;
      final newModel = PendingTopupModel(
        id: id,
        eventId: model.eventId,
        spbId: model.spbId,
        spgId: model.spgId,
        productId: model.productId,
        qty: model.qty,
        type: model.type,
        isChecked: model.isChecked,
        stockMutationId: model.stockMutationId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await db.insert('pending_topups', newModel.toMap());
      return newModel.toEntity();
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to create pending topup: $e');
    }
  }

  @override
  Future<PendingTopupEntity> update(PendingTopupEntity entity) async {
    try {
      final db = await dbHelper.database;
      final model = PendingTopupModel.fromEntity(entity);
      final updatedModel = PendingTopupModel(
        id: model.id,
        eventId: model.eventId,
        spbId: model.spbId,
        spgId: model.spgId,
        productId: model.productId,
        qty: model.qty,
        type: model.type,
        isChecked: model.isChecked,
        stockMutationId: model.stockMutationId,
        createdAt: model.createdAt,
        updatedAt: DateTime.now(),
      );
      await db.update(
        'pending_topups',
        updatedModel.toMap(),
        where: 'id = ?',
        whereArgs: [entity.id],
      );
      return updatedModel.toEntity();
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to update pending topup: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'pending_topups',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to delete pending topup: $e');
    }
  }

  @override
  Future<void> deleteByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'pending_topups',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
    } catch (e) {
      throw AppDatabaseException(message: 'Failed to delete pending topups by event: $e');
    }
  }
}