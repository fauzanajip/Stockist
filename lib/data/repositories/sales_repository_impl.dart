import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/sales_model.dart';
import '../../domain/entities/sales_entity.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class SalesRepositoryImpl implements SalesRepository {
  final DatabaseHelper dbHelper;

  SalesRepositoryImpl({required this.dbHelper});

  @override
  Future<Either<Failure, List<SalesEntity>>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sales',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      return Right(maps.map((map) => SalesModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data sales'));
    }
  }

  @override
  Future<Either<Failure, List<SalesEntity>>> getByEventAndSpg(String eventId, String spgId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sales',
        where: 'event_id = ? AND spg_id = ?',
        whereArgs: [eventId, spgId],
      );
      return Right(maps.map((map) => SalesModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data sales'));
    }
  }

  @override
  Future<Either<Failure, SalesEntity?>> getByEventSpgProduct(String eventId, String spgId, String productId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sales',
        where: 'event_id = ? AND spg_id = ? AND product_id = ?',
        whereArgs: [eventId, spgId, productId],
      );
      if (maps.isNotEmpty) {
        return Right(SalesModel.fromMap(maps.first));
      }
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data sales'));
    }
  }

  @override
  Future<Either<Failure, SalesEntity>> create(SalesEntity sales) async {
    try {
      final db = await dbHelper.database;
      final model = SalesModel(
        id: sales.id.isEmpty ? const Uuid().v4() : sales.id,
        eventId: sales.eventId,
        spgId: sales.spgId,
        productId: sales.productId,
        qtySold: sales.qtySold,
        updatedAt: sales.updatedAt,
        previousQty: sales.previousQty,
        createdAt: DateTime.now(),
      );
      await db.insert('sales', model.toMap());
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal membuat sales record'));
    }
  }

  @override
  Future<Either<Failure, SalesEntity>> update(SalesEntity sales) async {
    try {
      final db = await dbHelper.database;
      final model = SalesModel.fromEntity(sales).copyWith(
        updatedAt: DateTime.now(),
      );
      await db.update(
        'sales',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [sales.id],
      );
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal update sales record'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalSold(String eventId, String spgId, String productId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery('''
        SELECT qty_sold
        FROM sales
        WHERE event_id = ? AND spg_id = ? AND product_id = ?
      ''', [eventId, spgId, productId]);
      
      if (result.isNotEmpty && result.first['qty_sold'] != null) {
        return Right(result.first['qty_sold'] as int);
      }
      return const Right(0);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal menghitung total sold'));
    }
  }
}
