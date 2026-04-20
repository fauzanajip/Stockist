import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/event_product_model.dart';
import '../../domain/entities/event_product_entity.dart';
import '../../domain/repositories/event_product_repository.dart';
import '../../../core/error/exceptions.dart';

class EventProductRepositoryImpl implements EventProductRepository {
  final DatabaseHelper dbHelper;

  EventProductRepositoryImpl({required this.dbHelper});

  @override
  Future<List<EventProductEntity>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'event_products',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      return maps.map((map) => EventProductModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data Event Product: $e');
    }
  }

  @override
  Future<EventProductEntity?> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'event_products',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return EventProductModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data Event Product: $e');
    }
  }

  @override
  Future<EventProductEntity> create(EventProductEntity eventProduct) async {
    try {
      final db = await dbHelper.database;
      final model = EventProductModel(
        id: eventProduct.id.isEmpty ? const Uuid().v4() : eventProduct.id,
        eventId: eventProduct.eventId,
        productId: eventProduct.productId,
        price: eventProduct.price,
        createdAt: DateTime.now(),
      );
      await db.insert('event_products', model.toMap());
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal assign product ke event: $e');
    }
  }

  @override
  Future<EventProductEntity> update(EventProductEntity eventProduct) async {
    try {
      final db = await dbHelper.database;
      final model = EventProductModel.fromEntity(eventProduct);
      await db.update(
        'event_products',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [eventProduct.id],
      );
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal update Event Product: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'event_products',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal hapus Event Product: $e');
    }
  }

  @override
  Future<void> deleteByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'event_products',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal hapus Event Product: $e');
    }
  }
}
