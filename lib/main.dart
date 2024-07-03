import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Career Improvement App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Career Improvement App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isUserDataPresent = false;
  Map<String, String> additionalData = {};
  String _suggestions = '';

  @override
  void initState() {
    super.initState();
    _checkUserData();
  }

  Future<void> _checkUserData() async {
    Map<String, dynamic> userData = await _dbHelper.getUserData();
    setState(() {
      _isUserDataPresent = userData.isNotEmpty;
      additionalData = Map<String, String>.from(userData);
    });
  }

  void _submitForm() async {
    String name = _nameController.text;
    String age = _ageController.text;
    String education = _educationController.text;
    Map<String, dynamic> user = {
      'name': name,
      'age': age,
      'education': education,
    };

    await _dbHelper.insertUser(user);

    // Clear the text fields after saving
    _nameController.clear();
    _ageController.clear();
    _educationController.clear();

    // Check if user data is present and update the state
    await _checkUserData();
  }

  void _addKeyValuePair(String key, String value) async {
    await _dbHelper.insertUser({key: value});
    setState(() {
      additionalData[key] = value;
    });
  }

  Future<void> _getSuggestions() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    print('API Key: $apiKey');  // Ensure the API key is being loaded

    final url = 'https://api.openai.com/v1/chat/completions';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': 'You are a career advisor.'
        },
        {
          'role': 'user',
          'content': 'Based on the following information, suggest new job opportunities: ${additionalData.toString()}'
        }
      ],
    });

    print('Request URL: $url');
    print('Request Headers: $headers');
    print('Request Body: $body');

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _suggestions = data['choices'][0]['message']['content'];
        });
      } else {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
        setState(() {
          _suggestions = 'Failed to get suggestions. Please try again later.';
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _suggestions = 'Failed to get suggestions. Please try again later.';
      });
    }
  }

  Widget _buildInitialForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
        ),
        TextField(
          controller: _ageController,
          decoration: const InputDecoration(
            labelText: 'Age',
          ),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: _educationController,
          decoration: const InputDecoration(
            labelText: 'Highest Education Qualification',
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildAdditionalDataForm() {
    return Column(
      children: [
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                TextEditingController keyController = TextEditingController();
                TextEditingController valueController = TextEditingController();
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
                        _addKeyValuePair(
                            keyController.text, valueController.text);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text('Add Description'),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: additionalData.length,
            itemBuilder: (context, index) {
              String key = additionalData.keys.elementAt(index);
              String value = additionalData[key]!;
              return ListTile(
                title: Text('$key: $value'),
              );
            },
          ),
        ),
        if (additionalData.length >= 4)
          ElevatedButton(
            onPressed: _getSuggestions,
            child: const Text('Wizer Me'),
          ),
        const SizedBox(height: 20),
        Text(_suggestions),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _isUserDataPresent ? _buildAdditionalDataForm() : _buildInitialForm(),
        ),
      ),
    );
  }
}
