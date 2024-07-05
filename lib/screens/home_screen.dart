import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../widgets/key_value_pair_dialog.dart';
import 'suggestions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isUserDataPresent = false;
  Map<String, String> additionalData = {};

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
                return KeyValuePairDialog(onAdd: _addKeyValuePair);
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SuggestionsScreen(additionalData: additionalData)),
              );
            },
            child: const Text('Wizer Me'),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Improvement App'),
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
