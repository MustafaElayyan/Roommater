import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/grocery_item_entity.dart';
import '../controllers/grocery_controller.dart';

class GroceryScreen extends ConsumerStatefulWidget {
  const GroceryScreen({super.key});

  @override
  ConsumerState<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends ConsumerState<GroceryScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String? _validateName(String value) {
    final name = value.trim();
    if (name.isEmpty) {
      return 'Item name is required.';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(name)) {
      return 'Item name must contain at least one letter.';
    }
    return null;
  }

  Future<void> _addItem() async {
    final nameError = _validateName(_nameController.text);
    if (nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nameError)),
      );
      return;
    }

    final qty = int.tryParse(_qtyController.text.trim());
    await ref.read(groceryControllerProvider.notifier).addItem(
          name: _nameController.text.trim(),
          quantity: (qty == null || qty <= 0) ? 1 : qty,
        );
    if (!mounted) return;
    final state = ref.read(groceryControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${state.error}')),
      );
      return;
    }
    _nameController.clear();
    _qtyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final toBuyAsync = ref.watch(toBuyGroceriesProvider);
    final purchasedAsync = ref.watch(purchasedGroceriesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Item name',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Qty',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _addItem,
                child: const Text('Add'),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'To Buy'),
            Tab(text: 'Purchased'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _GroceryList(
                itemsAsync: toBuyAsync,
                isPurchasedList: false,
              ),
              _GroceryList(
                itemsAsync: purchasedAsync,
                isPurchasedList: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroceryList extends ConsumerWidget {
  const _GroceryList({
    required this.itemsAsync,
    required this.isPurchasedList,
  });

  final AsyncValue<List<GroceryItemEntity>> itemsAsync;
  final bool isPurchasedList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Failed to load groceries: $error')),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Text(isPurchasedList ? 'No purchased items yet' : 'No grocery items yet'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Dismissible(
              key: ValueKey(item.id),
              background: Container(
                color: Colors.red.withOpacity(0.2),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(Icons.delete_outline),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                ref.read(groceryControllerProvider.notifier).deleteItem(item.id);
              },
              child: CheckboxListTile(
                value: item.isPurchased,
                onChanged: (_) {
                  ref.read(groceryControllerProvider.notifier).togglePurchased(
                        item.id,
                        isPurchased: !item.isPurchased,
                      );
                },
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration: item.isPurchased ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text('Qty: ${item.quantity}'),
              ),
            );
          },
        );
      },
    );
  }
}
