import 'package:flutter/material.dart';

class KeyValuePairDialog extends StatelessWidget {
  final Function(String, String) onAdd;

  const KeyValuePairDialog({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final TextEditingController keyController = TextEditingController();
    final TextEditingController valueController = TextEditingController();

    return AlertDialog(
      title: const Text('Add Key-Value Pair'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: keyController,
            decoration: const InputDecoration(
              labelText: 'Key',
            ),
          ),
          TextField(
            controller: valueController,
            decoration: const InputDecoration(
              labelText: 'Value',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            onAdd(keyController.text, valueController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
