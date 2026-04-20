import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/stock_mutation_model.dart';
import '../../domain/entities/stock_mutation_entity.dart';
import '../../domain/repositories/stock_mutation_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class StockMutationRepositoryImpl implements StockMutationRepository {
  final DatabaseHelper dbHelper;

  StockMutationRepositoryImpl({required this.dbHelper});

  @override
  Future<Either<Failure, List<StockMutationEntity>>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_mutations',
        where: 'event_id = ?',
        whereArgs: [eventId],
        orderBy: 'timestamp DESC',
      );
      return Right(maps.map((map) => StockMutationModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data stock mutations'));
    }
  }

  @override
  Future<Either<Failure, List<StockMutationEntity>>> getByEventAndSpg(String eventId, String spgId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_mutations',
        where: 'event_id = ? AND spg_id = ?',
        whereArgs: [eventId, spgId],
        orderBy: 'timestamp DESC',
      );
      return Right(maps.map((map) => StockMutationModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data stock mutations'));
    }
  }

  @override
  Future<Either<Failure, List<StockMutationEntity>>> getByEventSpgProduct(String eventId, String spgId, String productId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_mutations',
        where: 'event_id = ? AND spg_id = ? AND product_id = ?',
        whereArgs: [eventId, spgId, productId],
        orderBy: 'timestamp DESC',
      );
      return Right(maps.map((map) => StockMutationModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data stock mutations'));
    }
  }

  @override
  Future<Either<Failure, StockMutationEntity>> create(StockMutationEntity mutation) async {
    try {
      final db = await dbHelper.database;
      final model = StockMutationModel(
        id: mutation.id.isEmpty ? const Uuid().v4() : mutation.id,
        eventId: mutation.eventId,
        spgId: mutation.spgId,
        productId: mutation.productId,
        qty: mutation.qty,
        type: mutation.type,
        timestamp: mutation.timestamp,
        note: mutation.note,
        createdAt: DateTime.now(),
      );
      await db.insert('stock_mutations', model.toMap());
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal membuat stock mutation'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'stock_mutations',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal hapus stock mutation'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalGiven(String eventId, String spgId, String productId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery('''
        SELECT SUM(qty) as total
        FROM stock_mutations
        WHERE event_id = ? AND spg_id = ? AND product_id = ?
        AND (type = 'initial' OR type = 'topup')
      ''', [eventId, spgId, productId]);
      
      if (result.isNotEmpty && result.first['total'] != null) {
        return Right(result.first['total'] as int);
      }
      return const Right(0);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal menghitung total given'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalReturn(String eventId, String spgId, String productId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery('''
        SELECT SUM(qty) as total
        FROM stock_mutations
        WHERE event_id = ? AND spg_id = ? AND product_id = ?
        AND type = 'return'
      ''', [eventId, spgId, productId]);
      
      if (result.isNotEmpty && result.first['total'] != null) {
        return Right(result.first['total'] as int);
      }
      return const Right(0);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal menghitung total return'));
    }
  }
}
