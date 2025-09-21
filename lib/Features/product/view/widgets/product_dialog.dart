import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/product_model.dart';
import '../../view_model/view_model.dart';

class ProductDialog extends StatefulWidget {
  final Product? product;

  ProductDialog({this.product});

  @override
  _ProductDialogState createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  String _selectedCategory = 'Cake';
  bool _isLoading = false;
  
  final List<String> _categories = [
    'Cake', 'Cupcake', 'Muffin', 'Tart', 'Cookie',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    if (widget.product != null) {
      _selectedCategory = widget.product!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a product name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _stockController,
              decoration: InputDecoration(labelText: 'Stock Quantity'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter stock quantity';
                }
                if (int.tryParse(value) == null || int.parse(value) < 0) {
                  return 'Please enter a valid quantity';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(labelText: 'Category'),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _saveProduct,
          child: Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
        
        if (widget.product == null) {
          await productViewModel.addProduct(
            _nameController.text.trim(),
            double.parse(_priceController.text),
            int.parse(_stockController.text),
            _selectedCategory,
          );
        } else {
          final updatedProduct = widget.product!.copyWith(
            name: _nameController.text.trim(),
            price: double.parse(_priceController.text),
            stock: int.parse(_stockController.text),
            category: _selectedCategory,
          );
          await productViewModel.updateProduct(updatedProduct);
        }

        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null 
                ? 'Product added successfully' 
                : 'Product updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}