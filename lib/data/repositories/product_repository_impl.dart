import 'package:sqflite/sqflite.dart';
import '../data_sources/database_helper.dart';
import '../models/product_model.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper dbHelper;

  ProductRepositoryImpl({required this.dbHelper});

  @override
  Future<Either<Failure, List<ProductEntity>>> getAll() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        orderBy: 'name ASC',
      );
      return Right(maps.map((map) => ProductModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data products'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getActive() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'deleted_at IS NULL',
        orderBy: 'name ASC',
      );
      return Right(maps.map((map) => ProductModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data active products'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity?>> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Right(ProductModel.fromMap(maps.first));
      }
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data product'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> create(ProductEntity product) async {
    try {
      final db = await dbHelper.database;
      final model = ProductModel.fromEntity(product);
      await db.insert('products', model.toMap());
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal membuat product baru'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> update(ProductEntity product) async {
    try {
      final db = await dbHelper.database;
      final model = ProductModel.fromEntity(product).copyWith(
        updatedAt: DateTime.now(),
      );
      await db.update(
        'products',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal update product'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal hapus product'));
    }
  }

  @override
  Future<Either<Failure, void>> softDelete(String id) async {
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
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal soft delete product'));
    }
  }
}
