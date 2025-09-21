import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/customer_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  SupabaseService._internal();
  factory SupabaseService() => _instance;

  late SupabaseClient _supabase;
  
  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://oskvxwirbellikovnow.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9la3Z2eHZpcmJlaGxseHZ2bm93Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzNzg3NjQsImV4cCI6MjA3Mzk1NDc2NH0.V31WdWxJHjoBIfE79PfhmUhJSJ12mTHrg5WYka6AtYQ',
    );
    _supabase = Supabase.instance.client;
  }

  // Customer operations
  Future<void> insertCustomer(Customer customer) async {
    await _supabase
        .from('customers')
        .insert(customer.toJson());
  }

  Future<void> updateCustomer(Customer customer) async {
    await _supabase
        .from('customers')
        .update(customer.toJson())
        .eq('id', customer.id);
  }

  Future<void> deleteCustomer(String customerId) async {
    await _supabase
        .from('customers')
        .update({'is_deleted': true, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', customerId);
  }

  Future<List<Customer>> getCustomerChanges({DateTime? since}) async {
    var query = _supabase
        .from('customers')
        .select();
    
    if (since != null) {
      query = query.gte('updated_at', since.toIso8601String());
    }

    final response = await query.order('updated_at');
    
    return (response as List<dynamic>)
        .map((json) => Customer.fromJson(json))
        .toList();
  }

  Future<bool> isConnected() async {
    try {
      await _supabase.from('customers').select().limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}