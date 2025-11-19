import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/l10n/l10n_extension.dart';
import 'package:suefery_partner/data/services/auth_service.dart';
import 'package:suefery_partner/presentation/home/order_cubit.dart';
import '../../data/models/order_model.dart';
import '../../data/models/quoted_item.dart';
import '../../locator.dart';
import 'edit_product_modal.dart';
import 'add_product_modal.dart';
import 'inventory_cubit.dart';
import 'scroll_behavior.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  

  @override
  Widget build(BuildContext context) {
    final auth = sl<AuthService>();
    // 1. Provide Cubits at the top level
    return MultiBlocProvider(
      providers: [
        // Initialize data immediately
        BlocProvider(create: (_) => OrderCubit()), 
        BlocProvider(create: (_) => InventoryCubit()..fetchInventory(auth.currentAppUser!.storeId)),
      ],
      // 2. DefaultTabController manages the state for us
      child: DefaultTabController(
        length: 2, 
        child: Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.appTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
              tabs: [
                Tab(
                  text: context.l10n.tabOrders,
                  icon: const Icon(Icons.shopping_basket),
                ),
                Tab(
                  text: context.l10n.tabInventory,
                  icon: const Icon(Icons.inventory),
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              OrderManagementTab(),     // Tab 1
              InventoryManagementTab(), // Tab 2
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 1: ORDER MANAGEMENT
// ============================================================================

class OrderManagementTab extends StatelessWidget {
  const OrderManagementTab({super.key});
  
  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final auth = sl<AuthService>();

    return BlocConsumer<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state.error.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.error), backgroundColor: Colors.red
          ));
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } 
        
        if (state.draftOrders.isEmpty && state.confirmedOrders.isEmpty) {
           return Center(child: Text(strings.noDraftOrders));
        }

        return RefreshIndicator(
          onRefresh: () async => context.read<OrderCubit>().loadOrders(auth.currentAppUser!.storeId),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Section 1: Drafts (Needs Quote)
              if (state.draftOrders.isNotEmpty) ...[
                 _buildDraftOrderSection(context, state.draftOrders),
                 const SizedBox(height: 20),
              ],
              
              // Section 2: Confirmed (Needs Packing)
              if (state.confirmedOrders.isNotEmpty) ...[
                 _buildConfirmedOrderSection(context, state.confirmedOrders),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraftOrderSection(BuildContext context, List<OrderModel> orders) {
    final strings = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.draftOrders, style: Theme.of(context).textTheme.headlineSmall),
        const Divider(),
        ...orders.map((order) => _buildDraftCard(context, order)),
      ],
    );
  }

  Widget _buildDraftCard(BuildContext context, OrderModel order) {
    final strings = context.l10n;
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.blue[50],
      child: ListTile(
        title: Text('${strings.order} #${order.id.substring(0, 6)}'),
        subtitle: Text(order.items.map((e) => e.description).join(', ')),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _showQuoteSheet(context, order),
          child: Text(strings.setPrice),
        ),
      ),
    );
  }

  Widget _buildConfirmedOrderSection(BuildContext context, List<OrderModel> orders) {
    final strings = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.confirmedOrders, style: Theme.of(context).textTheme.headlineSmall),
        const Divider(),
        ...orders.map((order) => Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${strings.order} #${order.id.substring(0, 6)}', style: Theme.of(context).textTheme.titleLarge),
                Text('Total: ${order.total?.toStringAsFixed(2) ?? 'N/A'} EGP'),
                const Divider(),
                ...order.items.map((item) => Text('${item.quantity}x ${item.description}')),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.read<OrderCubit>().markOrderReady(order.id),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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

  void _showQuoteSheet(BuildContext context, OrderModel order) {
    final orderCubit = context.read<OrderCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: orderCubit),
            BlocProvider(create: (_) => QuoteCubit(order)),
          ],
          child: QuoteOrderSheet(
            order: order,
            onConfirm: (quotedItems) {
              orderCubit.submitQuote(order.id, quotedItems);
              Navigator.of(sheetContext).pop();
            },
          ),
        );
      },
    );
  }
}

// ============================================================================
// TAB 2: INVENTORY MANAGEMENT
// ============================================================================

class InventoryManagementTab extends StatelessWidget {
  const InventoryManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final auth = sl<AuthService>();

    return Scaffold(
      body: BlocConsumer<InventoryCubit, InventoryState>(
        listener: (context, state) {
          if (state.error.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error), backgroundColor: Colors.red
            ));
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return RefreshIndicator(
            onRefresh: () async => context.read<InventoryCubit>().fetchInventory(auth.currentAppUser!.storeId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return Card(
                  child: SwitchListTile(
                    title: Text(product.description),
                    subtitle: Text('${product.price.toStringAsFixed(2)} EGP'),
                    value: product.isAvailable,
                    onChanged: (newValue) {
                      context.read<InventoryCubit>().toggleAvailability(product.id, newValue);
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    secondary: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => BlocProvider.value(
                            value: context.read<InventoryCubit>(),
                            child: EditProductModal(product: product),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => BlocProvider.value(
              value: context.read<InventoryCubit>(),
              child: const AddProductModal(),
            ),
          );
        },
        tooltip: strings.addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ============================================================================
// WIDGET: QUOTE ORDER SHEET (Needs State for Inputs)
// ============================================================================

class QuoteOrderSheet extends StatefulWidget {
  final OrderModel order;
  final void Function(List<QuotedItem> quotedItems) onConfirm;

  const QuoteOrderSheet({
    super.key,
    required this.order,
    required this.onConfirm,
  });

  @override
  State<QuoteOrderSheet> createState() => _QuoteOrderSheetState();
}

class _QuoteOrderSheetState extends State<QuoteOrderSheet> {
  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    return BlocBuilder<QuoteCubit, QuoteState>(
      builder: (context, quoteState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        Text(
                          strings.orderItems,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        ...quoteState.quotedItems.map((item) => _buildItemInput(context, item)),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey[300]),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                strings.totalQuote,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${quoteState.totalQuote.toStringAsFixed(2)} EGP',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildFooter(context, quoteState.totalQuote),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final strings = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            strings.quoteForOrder,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildItemInput(BuildContext context, QuotedItem quotedItem) {
    final strings = context.l10n;
    final item = quotedItem.item;
    final quoteCubit = context.read<QuoteCubit>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.quantity}x ${item.description}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                if (item.notes?.isNotEmpty ?? false)
                  Text(
                    '${strings.notes}: ${item.notes}',
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: TextFormField(
              initialValue: quotedItem.quotedPrice > 0 ? quotedItem.quotedPrice.toString() : null,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: strings.pricePerUnit,
                suffixText: 'EGP',
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                final newPrice = double.tryParse(value) ?? 0.0;
                quoteCubit.updateQuotedPrice(item, newPrice);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, double totalQuote) {
    final strings = context.l10n;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: totalQuote > 0
              ? () => widget.onConfirm(context.read<QuoteCubit>().getFinalQuotedItems())
              : null, 
          child: Text(
            '${strings.confirmQuote} (${totalQuote.toStringAsFixed(2)} EGP)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}