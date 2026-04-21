import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class GetAllProducts {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  Future<List<ProductEntity>> call() async {
    return await repository.getAll();
  }
}

class GetActiveProducts {
  final ProductRepository repository;

  GetActiveProducts(this.repository);

  Future<List<ProductEntity>> call() async {
    return await repository.getActive();
  }
}

class GetProductById {
  final ProductRepository repository;

  GetProductById(this.repository);

  Future<ProductEntity?> call(String id) async {
    return await repository.getById(id);
  }
}

class CreateProductParams {
  final String name;
  final String sku;
  final double price;

  CreateProductParams({
    required this.name,
    required this.sku,
    required this.price,
  });
}

class CreateProduct {
  final ProductRepository repository;

  CreateProduct(this.repository);

  Future<ProductEntity> call(CreateProductParams params) async {
    return await repository.create(
      ProductEntity(
        id: '',
        name: params.name,
        sku: params.sku,
        price: params.price,
      ),
    );
  }
}

class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<ProductEntity> call(ProductEntity product) async {
    return await repository.update(product);
  }
}

class SoftDeleteProduct {
  final ProductRepository repository;

  SoftDeleteProduct(this.repository);

  Future<void> call(String id) async {
    await repository.softDelete(id);
  }
}