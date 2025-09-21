import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../customer/repository/services/sync_service.dart';
import '../model/product_model.dart';
import '../repository/product_repository.dart';


class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = Uuid();

  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _repository.getAllProducts();
      _syncService.sync().catchError((e) => print('Background sync failed: $e'));
    } catch (e) {
      print('Failed to load products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(String name, double price, int stock, String category) async {
    try {
      final product = Product(
        id: _uuid.v4(),
        name: name,
        price: price,
        stock: stock,
        category: category,
      );

      await _repository.insertProduct(product);
      await loadProducts();
      
      _syncService.sync().catchError((e) => print('Background sync failed: $e'));
    } catch (e) {
      print('Failed to add product: $e');
      throw e;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _repository.updateProduct(product);
      await loadProducts();
      
      _syncService.sync().catchError((e) => print('Background sync failed: $e'));
    } catch (e) {
      print('Failed to update product: $e');
      throw e;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _repository.deleteProduct(productId);
      await loadProducts();
      
      _syncService.sync().catchError((e) => print('Background sync failed: $e'));
    } catch (e) {
      print('Failed to delete product: $e');
      throw e;
    }
  }

  Future<void> forceSync() async {
    try {
      await _syncService.sync();
      await loadProducts();
    } catch (e) {
      print('Force sync failed: $e');
    }
  }
}