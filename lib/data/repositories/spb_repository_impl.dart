import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/spb_model.dart';
import '../../domain/entities/spb_entity.dart';
import '../../domain/repositories/spb_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class SpbRepositoryImpl implements SpbRepository {
  final DatabaseHelper dbHelper;

  SpbRepositoryImpl({required this.dbHelper});

  @override
  Future<Either<Failure, List<SpbEntity>>> getAll() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'spbs',
        orderBy: 'name ASC',
      );
      return Right(maps.map((map) => SpbModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data SPB'));
    }
  }

  @override
  Future<Either<Failure, SpbEntity?>> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'spbs',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Right(SpbModel.fromMap(maps.first));
      }
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data SPB'));
    }
  }

  @override
  Future<Either<Failure, SpbEntity>> create(SpbEntity spb) async {
    try {
      final db = await dbHelper.database;
      final model = SpbModel(
        id: const Uuid().v4(),
        name: spb.name,
        createdAt: DateTime.now(),
      );
      await db.insert('spbs', model.toMap());
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal membuat SPB baru'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'spbs',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal hapus SPB'));
    }
  }
}
