import 'package:flutter/material.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final _controller = TextEditingController();
  final _qtyController = TextEditingController();
  final List<Map<String, dynamic>> _toBuy = [
    {'id': 'milk', 'name': 'Milk', 'qty': 2, 'checked': false},
    {'id': 'eggs', 'name': 'Eggs', 'qty': 12, 'checked': false},
    {'id': 'bread', 'name': 'Bread', 'qty': 1, 'checked': false},
    {'id': 'tomatoes', 'name': 'Tomatoes', 'qty': 6, 'checked': false},
  ];
  final List<Map<String, dynamic>> _purchased = [
    {'name': 'Rice', 'qty': 1, 'checked': true},
    {'name': 'Pasta', 'qty': 2, 'checked': true},
  ];

  @override
  void dispose() {
    _controller.dispose();
    _qtyController.dispose();
    super.dispose();
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
                  final parsedQty = int.tryParse(_qtyController.text.trim());
                  final qty = (parsedQty == null || parsedQty <= 0)
                      ? 1
                      : parsedQty;
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
