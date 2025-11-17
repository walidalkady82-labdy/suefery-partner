import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/l10n/l10n_extension.dart';
import 'package:suefery_partner/data/enums/order_status.dart';
import 'package:suefery_partner/presentation/home/home_cubit.dart';
import '../../data/models/order_model.dart';
import 'edit_product_modal.dart';
import '../auth/auth_cubit.dart';
import 'add_product_modal.dart';
import 'scroll_behavior.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    return DefaultTabController(
      length: 2, // Orders and Inventory
      child: Scaffold(
        appBar: AppBar(
          title: Text(strings.appTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout), // Consider moving to a profile/settings page
              onPressed: () => context.read<AuthCubit>().signOut(),
            )
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: strings.tabOrders, icon: const Icon(Icons.shopping_basket)),
              Tab(text: strings.tabInventory, icon: const Icon(Icons.inventory)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const OrderManagementTab(),
            const InventoryManagementTab(),
          ],
        ),
      ),
    );
  }
}

// --- 5.1. Order Management Tab ---
class OrderManagementTab extends StatelessWidget {
  const OrderManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final homeCubit = context.read<HomeCubit>();
   
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.isLoading && state.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final pendingOrders = state.orders.where((o) => o.status == OrderStatus.draft).toList();
        final preparingOrders = state.orders.where((o) => o.status == OrderStatus.preparing).toList();

        if (state.error.isNotEmpty) {
          return Center(child: Text(state.error));
        }

        if (state.orders.isEmpty && !state.isLoading) {
          return Center(child: Text(strings.welcome));
        }

        return RefreshIndicator(
          onRefresh: () => homeCubit.fetchOrders(),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildOrderSection(context, strings.newOrders, pendingOrders, true),
              const SizedBox(height: 20),
              _buildOrderSection(context, strings.preparing, preparingOrders, false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSection(BuildContext context, String title, List<OrderModel> orders, bool isPending) {
    final strings = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const Divider(),
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text(strings.noNewOrders)),
          )
        else
          ...orders.map((order) => Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.orderNumber(order.id.substring(0, 6)), style: Theme.of(context).textTheme.titleLarge),
                  Text(strings.totalPrice(order.total.toStringAsFixed(2), 'EGP')),
                  const Divider(),
                  ...order.items.map((item) => Text('${item.quantity}x ${item.name}')),
                  const SizedBox(height: 12),
                  if (isPending)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.read<HomeCubit>().acceptOrder(order.id),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: Text(strings.acceptOrder),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () { /* Add reject logic */ },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: Text(strings.rejectOrder),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.read<HomeCubit>().markOrderReady(order.id),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: Text(strings.orderReady),
                      ),
                    ),
                ],
              ),
            ),
          )),
      ],
    );
  }
}

// --- 5.2. Inventory Management Tab ---
class InventoryManagementTab extends StatelessWidget {
  const InventoryManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => BlocProvider.value(
              value: context.read<HomeCubit>(),
              child: const AddProductModal(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.isLoading && state.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.products.isEmpty && !state.isLoading && state.error.isEmpty) {
            return Center(child: Text(strings.welcome)); // Or a more specific "No products yet" message
          }

          final filteredProducts = state.filteredProducts;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (query) => context.read<HomeCubit>().searchInventory(query),
                  decoration: InputDecoration(
                    labelText: strings.search,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              if (state.error.isNotEmpty)
                Center(child: Text(state.error))
              else
                Expanded(
                  child: ScrollConfiguration(
                    behavior: AppScrollBehavior(),
                    child: RefreshIndicator(
                      onRefresh: () => context.read<HomeCubit>().fetchInventory(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return Card(
                            child: ListTile(
                              title: Text(product.description),
                              subtitle: Text('${product.price.toStringAsFixed(2)} EGP'),
                              leading: Switch(
                                value: product.isAvailable,
                                onChanged: (newValue) {
                                  context.read<HomeCubit>().toggleAvailability(product.productId, newValue);
                                },
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.red,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<HomeCubit>(),
                                      child: EditProductModal(product: product),
                                    ));
                                },
                              ),
                            ));
                        },
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
