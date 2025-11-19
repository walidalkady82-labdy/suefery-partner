import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/l10n/l10n_extension.dart';
import 'package:suefery_partner/presentation/home/order_cubit.dart';
import '../../data/models/order_model.dart';
import '../../data/models/quoted_item.dart';
import 'edit_product_modal.dart';
import 'add_product_modal.dart';
import 'inventory_cubit.dart';
import 'scroll_behavior.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    
    // 1. Watch the HomeCubit for state changes (e.g., new orders loading)
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OrderCubit()),
        BlocProvider(create: (_) => InventoryCubit()),
      ],
      child: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state.error.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.appTitle), // "SUEFERY Partner"
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    // Navigate to notifications or show list
                  },
                ),
              ],
            ),
            body: _buildBody(context,state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderState  state) {
    final strings = context.l10n;
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (!state.isLoading) {
      // Show Draft orders first (Priority)
      final draftOrders = state.draftOrders;

      if (draftOrders.isEmpty && state.confirmedOrders.isEmpty) {
        return Center(child: Text(strings.noDraftOrders));
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (draftOrders.isNotEmpty) ...[
            Text(
              strings.draftOrders, // "New Requests"
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ...draftOrders.map((order) => _buildOrderCard(context, order)),
            const Divider(height: 40),
          ],
          // You can add the Confirmed Orders list here as well
        ],
      );
    }
    return Center(child: Text(strings.welcome));
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final strings = context.l10n;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${strings.order} #${order.id.substring(0, 6)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    strings.needsQuote,
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Item Summary
            Text("${order.items.length} Items Requested:",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            // Display first 2 items as preview
            ...order.items.take(2).map((item) => Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("• ${item.quantity}x ${item.description}"),
            )),
            if (order.items.length > 2)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("... +${order.items.length - 2} more"),
              ),

            const SizedBox(height: 16),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showQuoteSheet(context, order),
                child: Text(context.l10n.setPrice), // "Send Quote"
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // THE BRIDGE PATTERN: Connecting Screen -> Sheet
  // ---------------------------------------------------
  void _showQuoteSheet(BuildContext context, OrderModel order) {
    // 1. Capture the specific HomeCubit instance from the current context.
    //    We must do this HERE, before we push the new route (the bottom sheet).
    final homeCubit = context.read<OrderCubit>();

    showModalBottomSheet(
      context: context,
      
      // 2. Enable full-height scrolling behavior for the keyboard
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (sheetContext) {
        // 3. Wrap the Sheet in BlocProvider.value
        //    This makes the existing 'homeCubit' available inside the sheet's context.
        return BlocProvider.value(
      value: homeCubit,
      child: BlocProvider( // Provide the QuoteCubit for the sheet itself
        create: (_) => QuoteCubit(order),
        child: QuoteOrderSheet(order: order, onConfirm: (quotedItems) {
              // Call the cubit to submit the quote
              homeCubit.submitQuote(order.id, quotedItems);
              // Close the bottom sheet
              Navigator.of(context).pop();
            },
            ),
        ));
      },
    );
  }
}

class OrderManagementTab extends StatelessWidget {
  const OrderManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;

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
        } else if (!state.isLoading) {
          return RefreshIndicator(
            onRefresh: () async {
              // We just need to trigger the cubit to reload,
              // but since it's stream-based, it's always live.
              // This is more for user feedback.
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildDraftOrderSection(context, state.draftOrders),
                const SizedBox(height: 20),
                _buildConfirmedOrderSection(context, state.confirmedOrders),
              ],
            ),
          );
        }
        return Center(child: Text(strings.loading));
      },
    );
  }

  /// NEW: Section for S1 Draft Orders (Need Quoting)
  Widget _buildDraftOrderSection(BuildContext context, List<OrderModel> orders) {
    final strings = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.draftOrders, style: Theme.of(context).textTheme.headlineSmall),
        const Divider(),
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text(strings.noDraftOrders)),
          )
        else
          ...orders.map((order) => Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            color: Colors.blue[50],
            child: ListTile(
              title: Text('Order #${order.id.substring(0, 6)} (S1 Draft)'),
              subtitle: Text(order.items.map((e) => e.description).join(', ')),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to the new Quote Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      // Provide the *existing* HomeCubit to the new screen
                      value: context.read<OrderCubit>(), // This is OrderCubit
                      child: BlocProvider( // Provide the QuoteCubit for the sheet
                        create: (_) => QuoteCubit(order),
                        child: QuoteOrderSheet(order: order, onConfirm: (quotedItems) {
                            context.read<OrderCubit>().submitQuote(order.id, quotedItems);
                            Navigator.of(context).pop();
                          },
                        ),
                    ),
                  ),
                ));
              },
            ),
          )),
      ],
    );
  }

  /// REFACTORED: Section for Confirmed Orders (Need Packing)
  Widget _buildConfirmedOrderSection(BuildContext context, List<OrderModel> orders) {
    final strings = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.confirmedOrders, style: Theme.of(context).textTheme.headlineSmall),
        const Divider(),
        if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text(strings.noConfirmedOrders)),
          )
        else
          ...orders.map((order) => Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${order.id.substring(0, 6)}', style: Theme.of(context).textTheme.titleLarge),
                  Text('Total: ${order.total?.toStringAsFixed(2) ?? 'N/A'} EGP'),
                  const Divider(),
                  ...order.items.map((item) => Text('${item.quantity}x ${item.description}')),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.read<OrderCubit>().markOrderReady(order.id),
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

class InventoryManagementTab extends StatelessWidget {
  const InventoryManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;

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
          } else if (!state.isLoading) {
            return RefreshIndicator(
              onRefresh: () async {
                // This is also stream-based, so just for UX
              },
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
          }
          return Center(child: Text(strings.loading));
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

class QuoteOrderSheet extends StatefulWidget {
  final OrderModel order;
  // accepts a list of QuotedItem objects instead of a single double price
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: strings.pricePerUnit,
                suffixText: 'EGP',
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                final newPrice = double.tryParse(value) ?? 0.0;
                // Dispatch the update to the QuoteCubit
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
              : null, // Disable if total price is 0
          child: Text(
            '${strings.confirmQuote} (${totalQuote.toStringAsFixed(2)} EGP)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}