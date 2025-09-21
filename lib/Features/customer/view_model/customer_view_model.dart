import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

import '../model/customer_model.dart';
import '../repository/customer_repository.dart';
import '../repository/services/sync_service.dart';

class CustomerViewModel extends ChangeNotifier {
  final CustomerRepository _repository = CustomerRepository();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = Uuid();

  List<Customer> _customers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Customer> get customers => _searchQuery.isEmpty 
      ? _customers 
      : _customers.where((customer) => 
          customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer.phone.contains(_searchQuery)).toList();
  
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Load all customers
  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _repository.getAllCustomers();
      // Try to sync in background
      _syncService.sync().catchError((e) {
        print('Background sync failed: $e');
      });
    } catch (e) {
      print('Failed to load customers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add new customer
  Future<void> addCustomer(String name, String phone, [String? email]) async {
    try {
      final customer = Customer(
        id: _uuid.v4(),
        name: name,
        phone: phone,
        email: email,
      );

      await _repository.insertCustomer(customer);
      await loadCustomers(); // Refresh the list
      
      // Try to sync in background
      _syncService.sync().catchError((e) {
        print('Background sync failed: $e');
      });
    } catch (e) {
      print('Failed to add customer: $e');
      throw e;
    }
  }

  // Update customer
  Future<void> updateCustomer(Customer customer) async {
    try {
      await _repository.updateCustomer(customer);
      await loadCustomers(); // Refresh the list
      
      // Try to sync in background
      _syncService.sync().catchError((e) {
        print('Background sync failed: $e');
      });
    } catch (e) {
      print('Failed to update customer: $e');
      throw e;
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _repository.deleteCustomer(customerId);
      await loadCustomers(); // Refresh the list
      
      // Try to sync in background
      _syncService.sync().catchError((e) {
        print('Background sync failed: $e');
      });
    } catch (e) {
      print('Failed to delete customer: $e');
      throw e;
    }
  }

  // Search customers
  void searchCustomers(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Force sync
  Future<void> forceSync() async {
    try {
      await _syncService.sync();
      await loadCustomers(); // Refresh after sync
    } catch (e) {
      print('Force sync failed: $e');
    }
  }
}