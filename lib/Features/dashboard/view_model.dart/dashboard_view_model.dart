import 'package:flutter/material.dart';
import '../../customer/repository/services/sync_service.dart';
import '../../product/model/product_model.dart';
import '../../product/repository/product_repository.dart';
import '../../sales/repository/sales_repository.dart';


class DashboardViewModel extends ChangeNotifier {
  final ProductRepository _productRepo = ProductRepository();
  final SalesRepository _salesRepo = SalesRepository();
  final SyncService _syncService = SyncService();

  double _todaysSales = 0.0;
  int _todaysSalesCount = 0;
  double _totalInventoryValue = 0.0;
  List<Product> _lowStockItems = [];
  bool _isLoading = false;

  // Getters
  double get todaysSales => _todaysSales;
  int get todaysSalesCount => _todaysSalesCount;
  double get totalInventoryValue => _totalInventoryValue;
  List<Product> get lowStockItems => _lowStockItems;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todaysSales = await _salesRepo.getTodaysSalesTotal();
      _todaysSalesCount = await _salesRepo.getTodaysSalesCount();
      _totalInventoryValue = await _productRepo.getTotalInventoryValue();
      _lowStockItems = await _productRepo.getLowStockProducts(threshold: 5);
      
      // Background sync
      _syncService.sync().catchError((e) => print('Background sync failed: $e'));
    } catch (e) {
      print('Failed to load dashboard data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> forceSync() async {
    try {
      await _syncService.sync();
      await loadDashboardData();
    } catch (e) {
      print('Force sync failed: $e');
    }
  }
}