import 'package:flutter/material.dart';

class JoinHouseholdScreen extends StatefulWidget {
  const JoinHouseholdScreen({super.key});

  @override
  State<JoinHouseholdScreen> createState() => _JoinHouseholdScreenState();
}

class _JoinHouseholdScreenState extends State<JoinHouseholdScreen> {
  final _controller = TextEditingController();
  static const _households = <String>[
    'Sunrise Apartment 4B',
    'Maple Residency',
    'Downtown Loft',
    'Green View House',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Household')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Autocomplete<String>(
              optionsBuilder: (value) {
                if (value.text.trim().isEmpty) return _households;
                return _households.where(
                  (h) => h.toLowerCase().contains(value.text.toLowerCase()),
                );
              },
              fieldViewBuilder:
                  (context, textController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Household name',
                  ),
                  onChanged: (value) => _controller.text = value,
                );
              },
              onSelected: (selection) => _controller.text = selection,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request sent successfully.')),
                );
              },
              child: const Text('Send Request'),
            ),
          ],
        ),
      ),
    );
  }
}
