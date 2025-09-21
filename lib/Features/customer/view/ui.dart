import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/utils/p_text_styles.dart';
import '../../common_widgets/custom_app_bar.dart';
import '../../common_widgets/custom_floating_action_button.dart';
import '../view_model/customer_view_model.dart';
import 'widgets/customer_dialog.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // Load customers when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerViewModel>(context, listen: false).loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerViewModel>(
      builder: (context, customerVM, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: "Customers",
            actions: [
              IconButton(
                icon: Icon(Icons.sync),
                onPressed: () => customerVM.forceSync(),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search customers...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              customerVM.searchCustomers('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => customerVM.searchCustomers(value),
                ),
              ),
              
              // Customer List
              Expanded(
                child: customerVM.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : customerVM.customers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: PColors.whiteColor.withOpacity(0.5),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  customerVM.searchQuery.isEmpty
                                      ? 'No customers yet'
                                      : 'No customers found',
                                  style: PTextStyles.bodyMedium.copyWith(
                                    color: PColors.whiteColor.withOpacity(0.7),
                                  ),
                                ),
                                if (customerVM.searchQuery.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Add your first customer',
                                      style: PTextStyles.bodySmall.copyWith(
                                        color: PColors.whiteColor.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => customerVM.loadCustomers(),
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: customerVM.customers.length,
                              itemBuilder: (context, index) {
                                final customer = customerVM.customers[index];
                                return Card(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: PColors.secondaryColor,
                                      child: Text(
                                        customer.name.isNotEmpty 
                                            ? customer.name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: PColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      customer.name,
                                      style: PTextStyles.bodyMedium,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.phone,
                                          style: PTextStyles.bodySmall,
                                        ),
                                        if (customer.email != null)
                                          Text(
                                            customer.email!,
                                            style: PTextStyles.bodySmall.copyWith(
                                              color: PColors.whiteColor.withOpacity(0.7),
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Sync status indicator
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: customer.synced 
                                                ? Colors.green 
                                                : Colors.orange,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        PopupMenuButton<String>(
                                          onSelected: (value) => _handleMenuAction(
                                            context, value, customer, customerVM,
                                          ),
                                          itemBuilder: (BuildContext context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, size: 16),
                                                  SizedBox(width: 8),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete, size: 16),
                                                  SizedBox(width: 8),
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    onTap: () => _showCustomerDialog(
                                      context, customer: customer,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
          floatingActionButton: CustomFloatingActionButton(
            onPressed: () => _showCustomerDialog(context),
          ),
        );
      },
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    customer,
    CustomerViewModel customerVM,
  ) {
    switch (action) {
      case 'edit':
        _showCustomerDialog(context, customer: customer);
        break;
      case 'delete':
        _showDeleteConfirmation(context, customer, customerVM);
        break;
    }
  }

  void _showCustomerDialog(BuildContext context, {customer}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomerDialog(customer: customer);
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    customer,
    CustomerViewModel customerVM,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Customer'),
          content: Text(
            'Are you sure you want to delete ${customer.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await customerVM.deleteCustomer(customer.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Customer deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete customer'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}