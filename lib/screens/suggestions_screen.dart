import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SuggestionsScreen extends StatefulWidget {
  final Map<String, String> additionalData;

  const SuggestionsScreen({super.key, required this.additionalData});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  String _suggestions = '';

  @override
  void initState() {
    super.initState();
    _getSuggestions();
  }

  Future<void> _getSuggestions() async {
    final suggestions = await ApiService.getSuggestions(widget.additionalData);
    setState(() {
      _suggestions = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Suggestions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(_suggestions.isEmpty ? 'Loading suggestions...' : _suggestions),
        ),
      ),
    );
  }
}
