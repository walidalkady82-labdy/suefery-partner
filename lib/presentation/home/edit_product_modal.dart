import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/l10n/l10n_extension.dart';
import 'package:suefery_partner/data/models/product_model.dart';

import 'inventory_cubit.dart';

class EditProductModal extends StatefulWidget {
  final ProductModel product;
  const EditProductModal({super.key, required this.product});

  @override
  State<EditProductModal> createState() => _EditProductModalState();
}

class _EditProductModalState extends State<EditProductModal> {
  final _formKey = GlobalKey<FormState>();
  late String _productDescription;
  late String _productBrand;
  late double _productPrice;
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _productDescription = widget.product.description;
    _productBrand = widget.product.brand;
    _productPrice = widget.product.price;
    _isAvailable = widget.product.isAvailable;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // MODIFIED: Call InventoryCubit
      context.read<InventoryCubit>().updateProduct(
            widget.product.id,
            _productDescription,
            _productBrand,
            _productPrice,
            _isAvailable,
          );
      Navigator.pop(context);
    }
  }

  void _delete() {
    // MODIFIED: Call InventoryCubit
    context.read<InventoryCubit>().deleteProduct(widget.product.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(strings.editProduct, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _productDescription,
              decoration: InputDecoration(labelText: strings.productDescription),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return strings.productDescriptionRequired;
                }
                return null;
              },
              onSaved: (value) => _productDescription = value!,
            ),
            TextFormField(
              initialValue: _productPrice.toString(),
              decoration: InputDecoration(labelText: strings.productPrice, prefixText: 'EGP '),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return strings.productPriceRequired;
                }
                if (double.tryParse(value) == null) {
                  return strings.productPriceInvalid;
                }
                return null;
              },
              onSaved: (value) => _productPrice = double.parse(value!),
            ),
            SwitchListTile(
              title: Text(strings.inStock),
              value: _isAvailable,
              onChanged: (newValue) {
                setState(() {
                  _isAvailable = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete),
                  label: Text(strings.delete),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(strings.cancel),
                    ),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(strings.save),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}