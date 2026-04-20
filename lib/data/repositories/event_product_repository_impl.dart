import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/event_product_model.dart';
import '../../domain/entities/event_product_entity.dart';
import '../../domain/repositories/event_product_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class EventProductRepositoryImpl implements EventProductRepository {
  final DatabaseHelper dbHelper;

  EventProductRepositoryImpl({required this.dbHelper});

  @override
  Future<Either<Failure, List<EventProductEntity>>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'event_products',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      return Right(maps.map((map) => EventProductModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data Event Product'));
    }
  }

  @override
  Future<Either<Failure, EventProductEntity?>> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'event_products',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Right(EventProductModel.fromMap(maps.first));
      }
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data Event Product'));
    }
  }

  @override
  Future<Either<Failure, EventProductEntity>> create(EventProductEntity eventProduct) async {
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
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal assign product ke event'));
    }
  }

  @override
  Future<Either<Failure, EventProductEntity>> update(EventProductEntity eventProduct) async {
    try {
      final db = await dbHelper.database;
      final model = EventProductModel.fromEntity(eventProduct);
      await db.update(
        'event_products',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [eventProduct.id],
      );
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal update Event Product'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'event_products',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal hapus Event Product'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'event_products',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal hapus Event Product'));
    }
  }
}
