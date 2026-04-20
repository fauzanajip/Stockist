import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getAll();
  Future<List<ProductEntity>> getActive();
  Future<ProductEntity?> getById(String id);
  Future<ProductEntity> create(ProductEntity product);
  Future<ProductEntity> update(ProductEntity product);
  Future<void> delete(String id);
  Future<void> softDelete(String id);
}
