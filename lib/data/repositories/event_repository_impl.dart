import 'package:sqflite/sqflite.dart';
import '../data_sources/database_helper.dart';
import '../models/event_model.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class EventRepositoryImpl implements EventRepository {
  final DatabaseHelper dbHelper;

  EventRepositoryImpl({required this.dbHelper});

  @override
  Future<Either<Failure, List<EventEntity>>> getAll() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        orderBy: 'date DESC',
      );
      return Right(maps.map((map) => EventModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data events'));
    }
  }

  @override
  Future<Either<Failure, EventEntity?>> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Right(EventModel.fromMap(maps.first));
      }
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data event'));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> create(EventEntity event) async {
    try {
      final db = await dbHelper.database;
      final model = EventModel.fromEntity(event);
      await db.insert('events', model.toMap());
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal membuat event baru'));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> update(EventEntity event) async {
    try {
      final db = await dbHelper.database;
      final model = EventModel.fromEntity(event).copyWith(
        updatedAt: DateTime.now(),
      );
      await db.update(
        'events',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal update event'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal hapus event'));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> closeEvent(String id) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'events',
        {
          'status': EventStatus.closed.name,
          'updated_at': DatabaseHelper.dateTimeToString(DateTime.now()),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      final event = await getById(id);
      return event.fold(
        (l) => Left(const DatabaseFailure(message: 'Gagal close event')),
        (r) => Right(r!),
      );
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal close event'));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> reopenEvent(String id) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'events',
        {
          'status': EventStatus.open.name,
          'updated_at': DatabaseHelper.dateTimeToString(DateTime.now()),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      final event = await getById(id);
      return event.fold(
        (l) => Left(const DatabaseFailure(message: 'Gagal reopen event')),
        (r) => Right(r!),
      );
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal reopen event'));
    }
  }
}
