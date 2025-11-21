import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/l10n/l10n_extension.dart';
import 'package:suefery_partner/data/enums/promotion_type.dart';
import 'package:suefery_partner/presentation/home/promotions_cubit.dart';

class AddPromoModal extends StatefulWidget {
  const AddPromoModal({super.key});

  @override
  State<AddPromoModal> createState() => _AddPromoModalState();
}

class _AddPromoModalState extends State<AddPromoModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();

  PromotionType _promotionType = PromotionType.percentage;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<PromoCubit>().addPromo(
            id:"",
            title: _titleController.text,
            description: _descriptionController.text,
            type: _promotionType,
            value: double.tryParse(_valueController.text) ?? 0.0,
            startDate: _startDate,
            endDate: _endDate,
            isActive: true,
          );
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != (isStart ? _startDate : _endDate)) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Promotion", style: Theme.of(context).textTheme.headlineSmall), // Replace with l10n
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              DropdownButtonFormField<PromotionType>(
                value: _promotionType,
                decoration: const InputDecoration(labelText: 'Promotion Type'),
                items: PromotionType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type == PromotionType.percentage ? 'Percentage Discount' : 'Fixed Amount Discount'));
                }).toList(),
                onChanged: (value) => setState(() => _promotionType = value!),
              ),
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(labelText: 'Value', suffixText: _promotionType == PromotionType.percentage ? '%' : '\$'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a value' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(onPressed: () => _selectDate(context, true), icon: const Icon(Icons.calendar_today), label: Text('Start: ${_startDate.toLocal().toString().split(' ')[0]}')),
                  TextButton.icon(onPressed: () => _selectDate(context, false), icon: const Icon(Icons.calendar_today), label: Text('End: ${_endDate.toLocal().toString().split(' ')[0]}')),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.cancel)),
                  ElevatedButton(onPressed: _submit, child: Text(strings.save)),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}