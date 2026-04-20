import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/cash_record_model.dart';
import '../../domain/entities/cash_record_entity.dart';
import '../../domain/repositories/cash_record_repository.dart';
import '../../../core/error/exceptions.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;

class CashRecordRepositoryImpl implements CashRecordRepository {
  final DatabaseHelper dbHelper;

  CashRecordRepositoryImpl({required this.dbHelper});

  @override
  Future<List<CashRecordEntity>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'cash_records',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      return maps.map((map) => CashRecordModel.fromMap(map)).toList();
    } catch (e) {
      throw const AppDatabaseException(message: 'Gagal mengambil data cash records: $e');
    }
  }

  @override
  Future<CashRecordEntity?> getByEventAndSpg(String eventId, String spgId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'cash_records',
        where: 'event_id = ? AND spg_id = ?',
        whereArgs: [eventId, spgId],
      );
      if (maps.isNotEmpty) {
        return CashRecordModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw const AppDatabaseException(message: 'Gagal mengambil data cash record: $e');
    }
  }

  @override
  Future<CashRecordEntity> create(CashRecordEntity cashRecord) async {
    try {
      final db = await dbHelper.database;
      final model = CashRecordModel(
        id: cashRecord.id.isEmpty ? const Uuid().v4() : cashRecord.id,
        eventId: cashRecord.eventId,
        spgId: cashRecord.spgId,
        cashReceived: cashRecord.cashReceived,
        qrisReceived: cashRecord.qrisReceived,
        note: cashRecord.note,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await db.insert('cash_records', model.toMap());
      return model;
    } catch (e) {
      throw const AppDatabaseException(message: 'Gagal membuat cash record: $e');
    }
  }

  @override
  Future<CashRecordEntity> update(CashRecordEntity cashRecord) async {
    try {
      final db = await dbHelper.database;
      final model = CashRecordModel.fromEntity(cashRecord).copyWith(
        updatedAt: DateTime.now(),
      );
      await db.update(
        'cash_records',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [cashRecord.id],
      );
      return model;
    } catch (e) {
      throw const AppDatabaseException(message: 'Gagal update cash record: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'cash_records',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw const AppDatabaseException(message: 'Gagal hapus cash record: $e');
    }
  }
}
