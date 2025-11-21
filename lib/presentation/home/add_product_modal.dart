import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/l10n/l10n_extension.dart';

import 'inventory_cubit.dart';


class AddProductModal extends StatefulWidget {
  const AddProductModal({super.key});

  @override
  State<AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal> {
  final _formKey = GlobalKey<FormState>();
  String _productDescription = '';
  String _productBrand = '';
  double _productPrice = 0.0;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<InventoryCubit>().addProduct(_productDescription,_productBrand, _productPrice);
      Navigator.pop(context);
    }
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
            Text(strings.addProduct, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
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
              decoration: InputDecoration(labelText: strings.productBrand),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return strings.productBrandRequired;
                }
                return null;
              },
              onSaved: (value) => _productBrand = value!,
            ),
            TextFormField(
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}