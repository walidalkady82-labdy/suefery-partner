import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/presentation/auth/auth_cubit.dart';

import 'package:suefery_partner/presentation/home/promotions_cubit.dart';

import 'add_promo_modal.dart';
import 'edit_promo_modal.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user's ID to fetch their promotions.
    final storeId = context.read<AuthCubit>().currentDbUser?.id;

    if (storeId == null || storeId.isEmpty) {
      return Scaffold(
        body: Center(child: Text('Error: User not found.')),
      );
    }

    return BlocProvider(
      create: (context) => PromoCubit()..fetchPromo(storeId),
      child: const _PromotionsView(),
    );
  }
}

class _PromotionsView extends StatelessWidget {
  const _PromotionsView();

  @override
  Widget build(BuildContext context) {

    return Scaffold(      
      body: BlocBuilder<PromoCubit, PromoState>(builder: (context, state) {
        if (state.isLoading && state.promotions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } 

        if (state.promotions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_offer_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No promotions created yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the \'+\' button to add your first promotion.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: state.promotions.length,
          itemBuilder: (context, index) {
            final promotion = state.promotions[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(promotion.title),
                subtitle: Text(promotion.description),                
                leading: Icon(
                  Icons.circle,
                  color: promotion.isActive ? Colors.green : Colors.grey,
                  size: 12,
                ),
                trailing: Chip(
                  label: Text(promotion.valueAsString),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => BlocProvider.value(
                      value: context.read<PromoCubit>(),
                      child: EditPromoModal(promotion: promotion),
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {          
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => BlocProvider.value(
              value: context.read<PromoCubit>(),
              child: const AddPromoModal(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}