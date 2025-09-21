import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../customer/model/customer_model.dart';
import '../../customer/repository/customer_repository.dart';
import '../../customer/repository/services/sync_service.dart';
import '../../product/model/product_model.dart';
import '../../product/repository/product_repository.dart';
import '../model/sale_item.dart';
import '../model/sale_model.dart';
import '../repository/sales_repository.dart';


class SalesViewModel extends ChangeNotifier {
  final SalesRepository _salesRepo = SalesRepository();
  final CustomerRepository _customerRepo = CustomerRepository();
  final ProductRepository _productRepo = ProductRepository();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = Uuid();

  List<Sale> _sales = [];
  List<Customer> _customers = [];
  List<Product> _products = [];
  List<SaleItem> _currentSaleItems = [];
  Customer? _selectedCustomer;
  bool _isLoading = false;

  // Getters
  List<Sale> get sales => _sales;
  List<Customer> get customers => _customers;
  List<Product> get products => _products;
  List<SaleItem> get currentSaleItems => _currentSaleItems;
  Customer? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;

  double get currentSaleTotal => _currentSaleItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  Future<void> loadSales() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sales = await _salesRepo.getAllSales();
      _syncService.sync().catchError((e) => print('Background sync failed: $e'));
    } catch (e) {
      print('Failed to load sales: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCustomersAndProducts() async {
    try {
      _customers = await _customerRepo.getAllCustomers();
      _products = await _productRepo.getAllProducts();
      notifyListeners();
    } catch (e) {
      print('Failed to load customers and products: $e');
    }
  }

  void selectCustomer(Customer customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void addItemToSale(Product product, int quantity) {
    if (quantity <= 0 || quantity > product.stock) return;

    // Check if item already exists
    final existingIndex = _currentSaleItems.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex != -1) {
      // Update existing item
      final existingItem = _currentSaleItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      
      if (newQuantity <= product.stock) {
        _currentSaleItems[existingIndex] = SaleItem(
          id: existingItem.id,
          saleId: '',
          productId: product.id,
          productName: product.name,
          quantity: newQuantity,
          unitPrice: product.price,
        );
      }
    } else {
      // Add new item
      _currentSaleItems.add(SaleItem(
        id: _uuid.v4(),
        saleId: '',
        productId: product.id,
        productName: product.name,
        quantity: quantity,
        unitPrice: product.price,
      ));
    }
    
    notifyListeners();
  }

  void removeItemFromSale(String itemId) {
    _currentSaleItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void clearCurrentSale() {
    _selectedCustomer = null;
    _currentSaleItems.clear();
    notifyListeners();
  }

  Future<bool> completeSale() async {
    if (_selectedCustomer == null || _currentSaleItems.isEmpty) {
      return false;
    }

    try {
      final saleId = _uuid.v4();
      final sale = Sale(
        id: saleId,
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        totalAmount: currentSaleTotal,
      );

      // Update sale items with sale ID
      final items = _currentSaleItems.map((item) => 
        SaleItem(
          id: item.id,
          saleId: saleId,
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
        )
      ).toList();

      // Create sale
      await _salesRepo.createSale(sale, items);

      // Update product stock
      for (final item in items) {
        final product = _products.firstWhere((p) => p.id == item.productId);
        await _productRepo.updateStock(product.id, product.stock - item.quantity);
      }

      // Clear current sale
      clearCurrentSale();

      // Refresh data
      await loadSales();
      await loadCustomersAndProducts();

      // Background sync
      _syncService.sync().catchError((e) => print('Background sync failed: $e'));

      return true;
    } catch (e) {
      print('Failed to complete sale: $e');
      return false;
    }
  }

  Future<List<SaleItem>> getSaleDetails(String saleId) async {
    try {
      return await _salesRepo.getSaleItems(saleId);
    } catch (e) {
      print('Failed to get sale details: $e');
      return [];
    }
  }

  Future<void> forceSync() async {
    try {
      await _syncService.sync();
      await loadSales();
    } catch (e) {
      print('Force sync failed: $e');
    }
  }
}