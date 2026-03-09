import 'package:cake_nest/Features/sales/model/sale_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Features/customer/model/customer_model.dart';
import '../Features/product/model/product_model.dart';
import '../Features/sales/model/sale_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  SupabaseService._internal();
  factory SupabaseService() => _instance;

  late SupabaseClient _supabase;
  
  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://oekvvxvirbehllxvvnow.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9la3Z2eHZpcmJlaGxseHZ2bm93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzNzg3NjQsImV4cCI6MjA3Mzk1NDc2NH0.V31WdWxJHjoBIfE79PfhmUhJSJ12mTHrg5WYka6AtYQ',
    );
    _supabase = Supabase.instance.client;
  }

  // Customer operations
  Future<void> insertCustomer(Customer customer) async {
    await _supabase.from('customers').insert(customer.toJson());
  }

  Future<void> updateCustomer(Customer customer) async {
    await _supabase.from('customers').update(customer.toJson()).eq('id', customer.id);
  }

  Future<void> deleteCustomer(String customerId) async {
    await _supabase
        .from('customers')
        .update({'is_deleted': true, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', customerId);
  }

  Future<List<Customer>> getCustomerChanges({DateTime? since}) async {
    var query = _supabase.from('customers').select();
    
    if (since != null) {
      query = query.gte('updated_at', since.toIso8601String());
    }

    final response = await query.order('updated_at');
    
    return (response as List<dynamic>)
        .map((json) => Customer.fromJson(json))
        .toList();
  }

  // Product operations
  Future<void> insertProduct(Product product) async {
    await _supabase.from('products').insert(product.toJson());
  }

  Future<void> updateProduct(Product product) async {
    await _supabase.from('products').update(product.toJson()).eq('id', product.id);
  }

  Future<void> deleteProduct(String productId) async {
    await _supabase
        .from('products')
        .update({'is_deleted': true, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', productId);
  }

  Future<List<Product>> getProductChanges({DateTime? since}) async {
    var query = _supabase.from('products').select();
    
    if (since != null) {
      query = query.gte('updated_at', since.toIso8601String());
    }

    final response = await query.order('updated_at');
    
    return (response as List<dynamic>)
        .map((json) => Product.fromJson(json))
        .toList();
  }

  // Sales operations
  // Future<void> insertSale(Sale sale, List<SaleItem> items) async {
  //   // Insert sale
  //   await _supabase.from('sales').insert(sale.toJson());
    
  //   // Insert sale items
  //   final itemsJson = items.map((item) => item.toJson()).toList();
  //   await _supabase.from('sale_items').insert(itemsJson);
  // }
Future<void> insertSale(Sale sale, List<SaleItem> items) async {
  try {
    // Try to insert sale first
    await _supabase.from('sales').insert(sale.toJson());
    print('Sale inserted successfully: ${sale.id}');
  } catch (e) {
    if (e.toString().contains('duplicate key') || e.toString().contains('23505')) {
      print('Sale ${sale.id} already exists, skipping insert');
      // Don't throw error, just continue to items
    } else {
      rethrow; // Re-throw other errors
    }
  }
  
  try {
    // Insert sale items (handle duplicates here too)
    final itemsJson = items.map((item) => item.toJson()).toList();
    
    // Delete existing items first to avoid duplicates
    await _supabase.from('sale_items').delete().eq('sale_id', sale.id);
    
    // Then insert new items
    await _supabase.from('sale_items').insert(itemsJson);
    print('Sale items inserted successfully for sale: ${sale.id}');
  } catch (e) {
    print('Failed to insert sale items: $e');
    rethrow;
  }
}
  Future<void> updateSale(Sale sale, List<SaleItem> items) async {
    // Update sale
    await _supabase.from('sales').update(sale.toJson()).eq('id', sale.id);
    
    // Delete existing items and insert new ones
    await _supabase.from('sale_items').delete().eq('sale_id', sale.id);
    
    final itemsJson = items.map((item) => item.toJson()).toList();
    await _supabase.from('sale_items').insert(itemsJson);
  }

  Future<void> deleteSale(String saleId) async {
    await _supabase
        .from('sales')
        .update({'is_deleted': true, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', saleId);
  }

  Future<List<Map<String, dynamic>>> getSalesChanges({DateTime? since}) async {
    var salesQuery = _supabase.from('sales').select();
    
    if (since != null) {
      salesQuery = salesQuery.gte('updated_at', since.toIso8601String());
    }

    final salesResponse = await salesQuery.order('updated_at');
    final sales = salesResponse as List<dynamic>;
    
    List<Map<String, dynamic>> result = [];
    
    for (var saleJson in sales) {
      final sale = Sale.fromJson(saleJson);
      
      // Get items for this sale
      final itemsResponse = await _supabase
          .from('sale_items')
          .select()
          .eq('sale_id', sale.id);
      
      final items = (itemsResponse as List<dynamic>)
          .map((json) => SaleItem.fromJson(json))
          .toList();
      
      result.add({
        'sale': sale,
        'items': items,
      });
    }
    
    return result;
  }

  Future<bool> isConnected() async {
  try {
    print('Testing Supabase connection...');
    print('Supabase URL: https://oskvxwirbellikovnow.supabase.co');
    
    final response = await _supabase.from('customers').select().limit(1);
    print('Supabase test successful: $response');
    return true;
  } catch (e) {
    print('Supabase connection failed: $e');
    print('Error details: ${e.toString()}');
    return false;
  }
}
}