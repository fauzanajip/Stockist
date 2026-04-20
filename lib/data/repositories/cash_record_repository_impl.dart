import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/cash_record_model.dart';
import '../../domain/entities/cash_record_entity.dart';
import '../../domain/repositories/cash_record_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class CashRecordRepositoryImpl implements CashRecordRepository {
  final DatabaseHelper dbHelper;

  CashRecordRepositoryImpl({required this.dbHelper});

  @override
  Future<Either<Failure, List<CashRecordEntity>>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'cash_records',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      return Right(maps.map((map) => CashRecordModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data cash records'));
    }
  }

  @override
  Future<Either<Failure, CashRecordEntity?>> getByEventAndSpg(String eventId, String spgId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'cash_records',
        where: 'event_id = ? AND spg_id = ?',
        whereArgs: [eventId, spgId],
      );
      if (maps.isNotEmpty) {
        return Right(CashRecordModel.fromMap(maps.first));
      }
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data cash record'));
    }
  }

  @override
  Future<Either<Failure, CashRecordEntity>> create(CashRecordEntity cashRecord) async {
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
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal membuat cash record'));
    }
  }

  @override
  Future<Either<Failure, CashRecordEntity>> update(CashRecordEntity cashRecord) async {
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
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal update cash record'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'cash_records',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal hapus cash record'));
    }
  }
}
