import 'package:sqflite/sqflite.dart';
import '../data_sources/database_helper.dart';
import '../models/spg_model.dart';
import '../../domain/entities/spg_entity.dart';
import '../../domain/repositories/spg_repository.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class SpgRepositoryImpl implements SpgRepository {
  final DatabaseHelper dbHelper;

  SpgRepositoryImpl({required this.dbHelper});

  @override
  Future<Either<Failure, List<SpgEntity>>> getAll() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'spgs',
        orderBy: 'name ASC',
      );
      return Right(maps.map((map) => SpgModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data SPG'));
    }
  }

  @override
  Future<Either<Failure, List<SpgEntity>>> getActive() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'spgs',
        where: 'deleted_at IS NULL',
        orderBy: 'name ASC',
      );
      return Right(maps.map((map) => SpgModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data active SPG'));
    }
  }

  @override
  Future<Either<Failure, SpgEntity?>> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'spgs',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Right(SpgModel.fromMap(maps.first));
      }
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data SPG'));
    }
  }

  @override
  Future<Either<Failure, SpgEntity>> create(SpgEntity spg) async {
    try {
      final db = await dbHelper.database;
      final model = SpgModel.fromEntity(spg);
      await db.insert('spgs', model.toMap());
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal membuat SPG baru'));
    }
  }

  @override
  Future<Either<Failure, SpgEntity>> update(SpgEntity spg) async {
    try {
      final db = await dbHelper.database;
      final model = SpgModel.fromEntity(spg).copyWith(
        updatedAt: DateTime.now(),
      );
      await db.update(
        'spgs',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [spg.id],
      );
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal update SPG'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'spgs',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal hapus SPG'));
    }
  }

  @override
  Future<Either<Failure, void>> softDelete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.update(
        'spgs',
        {
          'deleted_at': DatabaseHelper.dateTimeToString(DateTime.now()),
          'updated_at': DatabaseHelper.dateTimeToString(DateTime.now()),
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal soft delete SPG'));
    }
  }
}
