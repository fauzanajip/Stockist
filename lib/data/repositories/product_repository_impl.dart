import '../data_sources/database_helper.dart';
import '../models/product_model.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../core/error/exceptions.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper dbHelper;

  ProductRepositoryImpl({required this.dbHelper});

  @override
  Future<List<ProductEntity>> getAll() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        orderBy: 'name ASC',
      );
      return maps
          .map<ProductEntity>((map) => ProductModel.fromMap(map))
          .toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data products: $e');
    }
  }

  @override
  Future<List<ProductEntity>> getActive() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'deleted_at IS NULL',
        orderBy: 'name ASC',
      );
      return maps
          .map<ProductEntity>((map) => ProductModel.fromMap(map))
          .toList();
    } catch (e) {
      throw AppDatabaseException(
        message: 'Gagal mengambil data active products: $e',
      );
    }
  }

  @override
  Future<ProductEntity?> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return ProductModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data product: $e');
    }
  }

  Future<void> _checkDuplicateName(dynamic db, String name, [String? excludeId]) async {
    final List<Map<String, dynamic>> result = await db.query(
      'products',
      where: excludeId != null ? 'LOWER(name) = LOWER(?) AND id != ?' : 'LOWER(name) = LOWER(?)',
      whereArgs: excludeId != null ? [name, excludeId] : [name],
    );
    if (result.isNotEmpty) {
      throw AppDatabaseException(message: 'Product dengan nama tersebut sudah ada.');
    }
  }

  @override
  Future<ProductEntity> create(ProductEntity product) async {
    try {
      final db = await dbHelper.database;
      await _checkDuplicateName(db, product.name);
      final model = ProductModel.fromEntity(product);
      await db.insert('products', model.toMap());
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal membuat product baru: $e');
    }
  }

  @override
  Future<ProductEntity> update(ProductEntity product) async {
    try {
      final db = await dbHelper.database;
      await _checkDuplicateName(db, product.name, product.id);
      final model = ProductModel.fromEntity(
        product,
      ).copyWith(updatedAt: DateTime.now());
      await db.update(
        'products',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal update product: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete('products', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal hapus product: $e');
    }
  }

  @override
  Future<void> softDelete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'products',
        {
          'deleted_at': DatabaseHelper.dateTimeToString(DateTime.now()),
          'updated_at': DatabaseHelper.dateTimeToString(DateTime.now()),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal soft delete product: $e');
    }
  }
}
