import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/core/l10n/l10n_extension.dart';
import 'package:suefery_partner/data/services/auth_service.dart';
import 'package:suefery_partner/presentation/home/order_cubit.dart';
import '../../data/enums/promotions_status.dart';
import '../../data/models/analytics_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/quoted_item.dart';
import '../../locator.dart';
import '../auth/auth_cubit.dart';
import 'add_promotion_screen.dart';
import 'analytics_cubit.dart';
import 'edit_product_modal.dart';
import 'add_product_modal.dart';
import 'inventory_cubit.dart';
import 'promotions_cubit.dart';
import 'promotions_screen.dart';
import 'scroll_behavior.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;

    // Use BlocBuilder to wait for the AuthCubit to provide a valid user.
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final storeId = authState.user?.storeId;

        // Show a loading indicator until we have a valid storeId.
        if (storeId == null || storeId.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Once we have a storeId, provide the other cubits.
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => OrderCubit()..loadOrders(storeId)),
            BlocProvider(create: (_) => InventoryCubit()..fetchInventory(storeId)),
            BlocProvider(create: (_) => AnalyticsCubit()),
            BlocProvider(create: (_) => PromoCubit()),
          ],
          child: DefaultTabController(
        length: 4, 
        child: Scaffold(
          appBar: AppBar(
            title: Text(strings.appTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
              tabs: [
                Tab(
                  text: strings.tabOrders,
                  icon: const Icon(Icons.shopping_basket),
                ),
                Tab(
                  text: context.l10n.tabInventory,
                  icon: const Icon(Icons.inventory),
                ),
                Tab(
                  text: strings.tabAnalysis,
                  icon: const Icon(Icons.analytics),
                ),
                Tab(
                  text: "Promotions", // You can add this to your l10n file
                  icon: const Icon(Icons.local_offer),
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              OrderManagementTab(),
              InventoryManagementTab(),
              AnalyticsTab(),
              PromotionsScreen(), // Added the new promotions screen here
            ],
          ),
        ),
      ),
        );
      },
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
          onRefresh: () async => context.read<OrderCubit>().loadOrders(auth.currentAppUser!.storeId!),
          child: ScrollConfiguration(
            behavior: AppScrollBehavior(),
            child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Section 1: Drafts (Needs Quote)
              if (state.draftOrders.isNotEmpty) ...[
                 _buildDraftOrderSection(context, state.draftOrders),
              ],
              
              // NEW Section 2: Quoted (Awaiting Customer Confirmation)
              if (state.quotedOrders.isNotEmpty) ...[
                const SizedBox(height: 20), // Separator
                _buildQuotedOrdersSection(context, state.quotedOrders),
              ],

              // Section 3: Confirmed (Needs Packing)
              // Section 2: Confirmed (Needs Packing)
              if (state.confirmedOrders.isNotEmpty) ...[
                 _buildConfirmedOrderSection(context, state.confirmedOrders),
              ]
            ],
            ),
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
        Text(strings.draftOrders, style: Theme.of(context).textTheme.headlineSmall), // "Orders to Quote"
        const Divider(), // Separator
        ...orders.map((order) => _buildDraftOrderCard(context, order)),
      ],
    );
  }
  
  Widget _buildQuotedOrdersSection(BuildContext context, List<OrderModel> orders) {
    final strings = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quoted Orders", style: Theme.of(context).textTheme.headlineSmall),
        const Divider(),
        ...orders.map((order) => _buildQuotedOrderCard(context, order)),
      ],
    );
  }

  // Renamed from _buildDraftCard to _buildDraftOrderCard for clarity
  Widget _buildDraftOrderCard(BuildContext context, OrderModel order) {
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

  // NEW: Card for Quoted Orders (Awaiting Confirmation)
  Widget _buildQuotedOrderCard(BuildContext context, OrderModel order) {
    final strings = context.l10n;
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.orange[50], // Differentiate color
      child: ListTile(
        title: Text('${strings.order} #${order.id.substring(0, 6)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.items.map((e) => e.description).join(', ')),
            Text("Total: ${order.total?.toStringAsFixed(2) ?? 'N/A'} EGP", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Awaiting customer confirmation", style: TextStyle(color: Colors.orange[700], fontStyle: FontStyle.italic)), // Add to l10n
          ],
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
            onRefresh: () async => context.read<InventoryCubit>().fetchInventory(auth.currentAppUser!.storeId!),
            child: ScrollConfiguration(
              behavior: AppScrollBehavior(),
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

// ============================================================================
// TAB 3: Analytics
// ============================================================================


class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.l10n;

    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (context, state) {
        if (state is AnalyticsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnalyticsError) {
          return Center(child: Text(state.message));
        } else if (state is AnalyticsLoaded) {
          final data = state.analytics;
          return RefreshIndicator(
            onRefresh: () async {
              // Need to grab storeId from context or AuthCubit in a real app
              // For now assuming the cubit has what it needs or we trigger parent refresh
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. Performance Score Card
                _buildPerformanceCard(context, data),
                const SizedBox(height: 24),

                // 2. Key Metrics Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _buildMetricCard(
                      context, 
                      strings.revenueThisMonth, 
                      '${data.totalRevenue.toStringAsFixed(0)} EGP',
                      Icons.attach_money,
                      Colors.green
                    ),
                    _buildMetricCard(
                      context, 
                      strings.totalOrders, 
                      data.totalOrders.toString(),
                      Icons.shopping_bag,
                      Colors.blue
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Top Items List
                Text(strings.mostWantedItems, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                if (data.topItems.isEmpty)
                   Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Text(strings.noDataYet, style: const TextStyle(color: Colors.grey)),
                   )
                else
                  ...data.topItems.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        child: Text('${item.count}x', style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(item.name),
                      trailing: Text('${item.revenue.toStringAsFixed(0)} EGP'),
                    ),
                  )),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPerformanceCard(BuildContext context, AnalyticsModel data) {
    final theme = Theme.of(context);
    final strings = context.l10n;

    // Determine color based on score
    Color statusColor = Colors.green;
    String statusText = strings.statusExcellent;
    if (data.partnerScore < 80) {
      statusColor = Colors.orange;
      statusText = strings.statusGood;
    } 
    if (data.partnerScore < 50) {
      statusColor = Colors.red;
      statusText = strings.statusAtRisk;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(strings.partnerPerformance, style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: data.partnerScore / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[200],
                        color: statusColor,
                      ),
                      Center(
                        child: Text(
                          '${data.partnerScore}%',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      "${(data.fulfillmentRate * 100).toStringAsFixed(0)}% ${strings.fulfillmentRate}",
                      style: theme.textTheme.bodySmall
                    ),
                    const SizedBox(height: 4),
                     Text(
                      strings.keepItUp,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 4: Promotion
// ============================================================================

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
      appBar: AppBar(
        title: const Text('Manage Promotions'),
      ),
      body: BlocBuilder<PromoCubit, PromoState>(builder: (context, state) {
        if (state.status == PromotionsStatus.loading && state.promotions.isEmpty) {
          return Center(child: CircularProgressIndicator());
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
                trailing: Chip(
                  label: Text(promotion.valueAsString),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // We wrap AddPromotionScreen with the existing BlocProvider
          // so it can access the same PromotionsCubit instance.
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<PromoCubit>(),
              child: const AddPromotionScreen(),
            ),
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}