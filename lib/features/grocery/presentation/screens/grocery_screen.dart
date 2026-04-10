import 'package:flutter/material.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final _controller = TextEditingController();
  final _qtyController = TextEditingController();
  final List<Map<String, dynamic>> _toBuy = [];
  final List<Map<String, dynamic>> _purchased = [];

  @override
  void dispose() {
    _controller.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  /// Parses quantity input and defaults to 1 for invalid or non-positive values.
  int _parseQuantity(String text) {
    final parsedQty = int.tryParse(text.trim());
    if (parsedQty == null || parsedQty <= 0) {
      return 1;
    }
    return parsedQty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Add item'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Qty'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  if (_controller.text.trim().isEmpty) return;
                  final qty = _parseQuantity(_qtyController.text);
                  setState(() {
                    _toBuy.add({
                      'id': '${_controller.text.trim()}-${DateTime.now().microsecondsSinceEpoch}',
                      'name': _controller.text.trim(),
                      'qty': qty,
                      'checked': false,
                    });
                    _controller.clear();
                    _qtyController.clear();
                  });
                },
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('To Buy', style: Theme.of(context).textTheme.titleMedium),
          if (_toBuy.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No grocery items yet'),
            ),
          ..._toBuy.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Dismissible(
              key: ValueKey(item['id']),
              onDismissed: (_) => setState(() => _toBuy.removeAt(index)),
              child: CheckboxListTile(
                value: item['checked'] as bool,
                onChanged: (value) => setState(() => item['checked'] = value),
                title: Text(item['name'] as String),
                secondary: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => setState(() {
                        final currentQty = item['qty'] as int;
                        item['qty'] = currentQty > 1 ? currentQty - 1 : 1;
                      }),
                    ),
                    CircleAvatar(
                      radius: 12,
                      child: Text('${item['qty']}'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() {
                        final currentQty = item['qty'] as int;
                        item['qty'] = currentQty + 1;
                      }),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Text('Purchased', style: Theme.of(context).textTheme.titleMedium),
          if (_purchased.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No purchased items yet'),
            ),
          ..._purchased.map(
            (item) => CheckboxListTile(
              value: item['checked'] as bool,
              onChanged: (value) => setState(() => item['checked'] = value),
              title: Text(
                item['name'] as String,
                style: const TextStyle(decoration: TextDecoration.lineThrough),
              ),
              secondary: CircleAvatar(
                radius: 12,
                child: Text('${item['qty']}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
