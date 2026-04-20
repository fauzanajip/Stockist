import 'package:sqflite/sqflite.dart' hide DatabaseException;
import '../data_sources/database_helper.dart';
import '../models/event_model.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../../../core/error/exceptions.dart';

class EventRepositoryImpl implements EventRepository {
  final DatabaseHelper dbHelper;

  EventRepositoryImpl({required this.dbHelper});

  @override
  Future<List<EventEntity>> getAll() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        orderBy: 'date DESC',
      );
      return maps.map((map) => EventModel.fromMap(map)).toList();
    } catch (e) {
      throw const AppDatabaseException(message: 'Gagal mengambil data events');
    }
  }

  @override
  Future<EventEntity?> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return EventModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw const AppDatabaseException(message: 'Gagal mengambil data event');
    }
  }

  @override
  Future<EventEntity> create(EventEntity event) async {
    try {
      final db = await dbHelper.database;
      final model = EventModel.fromEntity(event);
      await db.insert('events', model.toMap());
      return model;
    } catch (e) {
      throw const AppDatabaseException(message: 'Gagal membuat event baru');
    }
  }

  @override
  Future<EventEntity> update(EventEntity event) async {
    try {
      final db = await dbHelper.database;
      final model = EventModel.fromEntity(event).copyWith(
        updatedAt: DateTime.now(),
      );
      await db.update(
        'events',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [event.id],
      );
      return model;
    } catch (e) {
      throw const AppDatabaseException(message: 'Gagal update event');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'events',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw const AppDatabaseException(message: 'Gagal hapus event');
    }
  }

  @override
  Future<EventEntity> closeEvent(String id) async {
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
      if (event == null) {
        throw const AppNotFoundException(message: 'Event not found');
      }
      return event;
    } catch (e) {
      throw const AppDatabaseException(message: 'Gagal close event');
    }
  }

  @override
  Future<EventEntity> reopenEvent(String id) async {
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
      if (event == null) {
        throw const AppNotFoundException(message: 'Event not found');
      }
      return event;
    } catch (e) {
      throw const AppDatabaseException(message: 'Gagal reopen event');
    }
  }
}
