import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/stock_mutation_model.dart';
import '../../domain/entities/stock_mutation_entity.dart';
import '../../domain/repositories/stock_mutation_repository.dart';
import '../../../core/error/exceptions.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;

class StockMutationRepositoryImpl implements StockMutationRepository {
  final DatabaseHelper dbHelper;

  StockMutationRepositoryImpl({required this.dbHelper});

  @override
  Future<List<StockMutationEntity>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_mutations',
        where: 'event_id = ?',
        whereArgs: [eventId],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => StockMutationModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data stock mutations: $e');
    }
  }

  @override
  Future<List<StockMutationEntity>> getByEventAndSpg(String eventId, String spgId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_mutations',
        where: 'event_id = ? AND spg_id = ?',
        whereArgs: [eventId, spgId],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => StockMutationModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data stock mutations: $e');
    }
  }

  @override
  Future<List<StockMutationEntity>> getByEventSpgProduct(String eventId, String spgId, String productId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stock_mutations',
        where: 'event_id = ? AND spg_id = ? AND product_id = ?',
        whereArgs: [eventId, spgId, productId],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => StockMutationModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data stock mutations: $e');
    }
  }

  @override
  Future<StockMutationEntity> create(StockMutationEntity mutation) async {
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
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal membuat stock mutation: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'stock_mutations',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal hapus stock mutation: $e');
    }
  }

  @override
  Future<int> getTotalGiven(String eventId, String spgId, String productId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery('''
        SELECT SUM(qty) as total
        FROM stock_mutations
        WHERE event_id = ? AND spg_id = ? AND product_id = ?
        AND (type = 'initial' OR type = 'topup')
      ''', [eventId, spgId, productId]);
      
      if (result.isNotEmpty && result.first['total'] != null) {
        return result.first['total'] as int;
      }
      return 0;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal menghitung total given: $e');
    }
  }

  @override
  Future<int> getTotalReturn(String eventId, String spgId, String productId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery('''
        SELECT SUM(qty) as total
        FROM stock_mutations
        WHERE event_id = ? AND spg_id = ? AND product_id = ?
        AND type = 'returnMutation'
      ''', [eventId, spgId, productId]);
      
      if (result.isNotEmpty && result.first['total'] != null) {
        return result.first['total'] as int;
      }
      return 0;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal menghitung total return: $e');
    }
  }
}
