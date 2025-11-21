import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/data/models/promotion_model.dart';

import '../../data/enums/promotion_type.dart';
import 'promotions_cubit.dart';

class AddPromotionScreen extends StatefulWidget {
  const AddPromotionScreen({super.key});

  @override
  State<AddPromotionScreen> createState() => _AddPromotionScreenState();
}

class _AddPromotionScreenState extends State<AddPromotionScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Promotion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                context.read<PromoCubit>().addPromo(
                      id:'',
                      title: _titleController.text,
                      description: _descriptionController.text,
                      type: _promotionType,
                      value: double.tryParse(_valueController.text) ?? 0.0,
                      startDate: _startDate,
                      endDate: _endDate,
                      isActive: true,
                    );
                // Listen for state changes to pop, or pop immediately.
                // Popping immediately gives a faster user feedback.
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PromotionType>(
                value: _promotionType,
                decoration: const InputDecoration(labelText: 'Promotion Type', border: OutlineInputBorder()),
                items: PromotionType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type == PromotionType.percentage ? 'Percentage Discount' : 'Fixed Amount Discount'));
                }).toList(),
                onChanged: (value) => setState(() => _promotionType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(labelText: 'Value', suffixText: _promotionType == PromotionType.percentage ? '%' : '\$', border: const OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a value' : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(onPressed: () => _selectDate(context, true), icon: const Icon(Icons.calendar_today), label: Text('Start: ${_startDate.toLocal().toString().split(' ')[0]}')),
                  ElevatedButton.icon(onPressed: () => _selectDate(context, false), icon: const Icon(Icons.calendar_today), label: Text('End: ${_endDate.toLocal().toString().split(' ')[0]}')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}