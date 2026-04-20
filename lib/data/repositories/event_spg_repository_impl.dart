import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/event_spg_model.dart';
import '../../domain/entities/event_spg_entity.dart';
import '../../domain/repositories/event_spg_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class EventSpgRepositoryImpl implements EventSpgRepository {
  final DatabaseHelper dbHelper;

  EventSpgRepositoryImpl({required this.dbHelper});

  @override
  Future<Either<Failure, List<EventSpgEntity>>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'event_spgs',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      return Right(maps.map((map) => EventSpgModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data Event SPG'));
    }
  }

  @override
  Future<Either<Failure, EventSpgEntity?>> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'event_spgs',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Right(EventSpgModel.fromMap(maps.first));
      }
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data Event SPG'));
    }
  }

  @override
  Future<Either<Failure, EventSpgEntity>> create(EventSpgEntity eventSpg) async {
    try {
      final db = await dbHelper.database;
      final model = EventSpgModel(
        id: eventSpg.id.isEmpty ? const Uuid().v4() : eventSpg.id,
        eventId: eventSpg.eventId,
        spgId: eventSpg.spgId,
        spbId: eventSpg.spbId,
        createdAt: DateTime.now(),
      );
      await db.insert('event_spgs', model.toMap());
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal assign SPG ke event'));
    }
  }

  @override
  Future<Either<Failure, EventSpgEntity>> update(EventSpgEntity eventSpg) async {
    try {
      final db = await dbHelper.database;
      final model = EventSpgModel.fromEntity(eventSpg);
      await db.update(
        'event_spgs',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [eventSpg.id],
      );
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal update Event SPG'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'event_spgs',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal hapus Event SPG'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'event_spgs',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal hapus Event SPG'));
    }
  }
}
