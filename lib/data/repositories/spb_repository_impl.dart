import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/spb_model.dart';
import '../../domain/entities/spb_entity.dart';
import '../../domain/repositories/spb_repository.dart';
import '../../../core/error/exceptions.dart';

class SpbRepositoryImpl implements SpbRepository {
  final DatabaseHelper dbHelper;

  SpbRepositoryImpl({required this.dbHelper});

  @override
  Future<List<SpbEntity>> getAll() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'spbs',
        orderBy: 'name ASC',
      );
      return maps.map<SpbEntity>((map) => SpbModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data SPB: $e');
    }
  }

  @override
  Future<SpbEntity?> getById(String id) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'spbs',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return SpbModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data SPB: $e');
    }
  }

  @override
  Future<SpbEntity> create(SpbEntity spb) async {
    try {
      final db = await dbHelper.database;
      final model = SpbModel(
        id: const Uuid().v4(),
        name: spb.name,
        createdAt: DateTime.now(),
      );
      await db.insert('spbs', model.toMap());
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal membuat SPB baru: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'spbs',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal hapus SPB: $e');
    }
  }
}
