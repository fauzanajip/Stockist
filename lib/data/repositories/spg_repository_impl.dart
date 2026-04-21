import '../data_sources/database_helper.dart';
import '../models/spg_model.dart';
import '../../domain/entities/spg_entity.dart';
import '../../domain/repositories/spg_repository.dart';
import '../../../core/error/exceptions.dart';

class SpgRepositoryImpl implements SpgRepository {
  final DatabaseHelper dbHelper;

  SpgRepositoryImpl({required this.dbHelper});

  @override
  Future<List<SpgEntity>> getAll() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'spgs',
        orderBy: 'name ASC',
      );
      return maps.map<SpgEntity>((map) => SpgModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data SPG: $e');
    }
  }

  @override
  Future<List<SpgEntity>> getActive() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'spgs',
        where: 'deleted_at IS NULL',
        orderBy: 'name ASC',
      );
      return maps.map<SpgEntity>((map) => SpgModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data active SPG: $e');
    }
  }

  @override
  Future<SpgEntity?> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'spgs',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return SpgModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data SPG: $e');
    }
  }

  @override
  Future<SpgEntity> create(SpgEntity spg) async {
    try {
      final db = await dbHelper.database;
      final model = SpgModel.fromEntity(spg);
      await db.insert('spgs', model.toMap());
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal membuat SPG baru: $e');
    }
  }

  @override
  Future<SpgEntity> update(SpgEntity spg) async {
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
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal update SPG: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'spgs',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal hapus SPG: $e');
    }
  }

  @override
  Future<void> softDelete(String id) async {
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
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal soft delete SPG: $e');
    }
  }
}
