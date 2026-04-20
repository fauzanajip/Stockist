import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/sales_model.dart';
import '../../domain/entities/sales_entity.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../../core/error/exceptions.dart';

class SalesRepositoryImpl implements SalesRepository {
  final DatabaseHelper dbHelper;

  SalesRepositoryImpl({required this.dbHelper});

  @override
  Future<List<SalesEntity>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sales',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      return maps.map((map) => SalesModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data sales: $e');
    }
  }

  @override
  Future<List<SalesEntity>> getByEventAndSpg(String eventId, String spgId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sales',
        where: 'event_id = ? AND spg_id = ?',
        whereArgs: [eventId, spgId],
      );
      return maps.map((map) => SalesModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data sales: $e');
    }
  }

  @override
  Future<SalesEntity?> getByEventSpgProduct(String eventId, String spgId, String productId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sales',
        where: 'event_id = ? AND spg_id = ? AND product_id = ?',
        whereArgs: [eventId, spgId, productId],
      );
      if (maps.isNotEmpty) {
        return SalesModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data sales: $e');
    }
  }

  @override
  Future<SalesEntity> create(SalesEntity sales) async {
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
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal membuat sales record: $e');
    }
  }

  @override
  Future<SalesEntity> update(SalesEntity sales) async {
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
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal update sales record: $e');
    }
  }

  @override
  Future<int> getTotalSold(String eventId, String spgId, String productId) async {
    try {
      final db = await dbHelper.database;
      final result = await db.rawQuery('''
        SELECT qty_sold
        FROM sales
        WHERE event_id = ? AND spg_id = ? AND product_id = ?
      ''', [eventId, spgId, productId]);
      
      if (result.isNotEmpty && result.first['qty_sold'] != null) {
        return result.first['qty_sold'] as int;
      }
      return 0;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal menghitung total sold: $e');
    }
  }
}
