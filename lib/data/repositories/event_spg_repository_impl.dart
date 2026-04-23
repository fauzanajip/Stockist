import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/event_spg_model.dart';
import '../../domain/entities/event_spg_entity.dart';
import '../../domain/repositories/event_spg_repository.dart';
import '../../../core/error/exceptions.dart';

class EventSpgRepositoryImpl implements EventSpgRepository {
  final DatabaseHelper dbHelper;

  EventSpgRepositoryImpl({required this.dbHelper});

  @override
  Future<List<EventSpgEntity>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'event_spgs',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      return maps
          .map<EventSpgEntity>((map) => EventSpgModel.fromMap(map))
          .toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data Event SPG: $e');
    }
  }

  @override
  Future<EventSpgEntity?> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'event_spgs',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return EventSpgModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data Event SPG: $e');
    }
  }

  @override
  Future<EventSpgEntity> create(EventSpgEntity eventSpg) async {
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
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal assign SPG ke event: $e');
    }
  }

  @override
  Future<EventSpgEntity> update(EventSpgEntity eventSpg) async {
    try {
      final db = await dbHelper.database;
      final model = EventSpgModel.fromEntity(eventSpg);
      await db.update(
        'event_spgs',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [eventSpg.id],
      );
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal update Event SPG: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete('event_spgs', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal hapus Event SPG: $e');
    }
  }

  @override
  Future<void> deleteByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'event_spgs',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal hapus Event SPG: $e');
    }
  }
}
