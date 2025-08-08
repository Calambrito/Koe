import 'package:flutter/material.dart';
import 'package:koe/pages/view_as_user_usernamecheck.dart';
import 'login_page.dart';
import '../backend/admin.dart';
import '../backend/theme.dart';
import '../backend/database_helper.dart';

class AdminPage extends StatefulWidget {
  final String userId;
  const AdminPage({super.key, required this.userId});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _songNameController = TextEditingController();
  final _urlController = TextEditingController();
  final _durationController = TextEditingController();
  final _genreController = TextEditingController();
  final _artistController = TextEditingController();
  final List<String> _artistNames = [];
  bool _isLoading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadArtistNames();
  }

  Future<void> _loadArtistNames() async {
    final db = await DatabaseHelper.getInstance().database;
    final rows = await db.query(
      'Artist',
      columns: ['artist_name'],
      orderBy: 'artist_name ASC',
    );
    setState(() {
      _artistNames.clear();
      _artistNames.addAll(rows.map((r) => r['artist_name'] as String));
    });
  }

  Future<void> _addSong() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final admin = Admin(
        userID: widget.userId,
        username: 'Admin',
        theme: KoeTheme.green,
      );

      await admin.addSong(
        songName: _songNameController.text,
        url: _urlController.text,
        duration: _durationController.text.isEmpty
            ? null
            : _durationController.text,
        genre: _genreController.text.isEmpty ? null : _genreController.text,
        artistName: _artistController.text,
      );

      setState(() => _message = 'Song added successfully!');
      _clearForm();
      await _loadArtistNames();
    } catch (e) {
      setState(() => _message = 'Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _songNameController.clear();
    _urlController.clear();
    _durationController.clear();
    _genreController.clear();
    _artistController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Add New Song',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              TextFormField(
                controller: _songNameController,
                decoration: const InputDecoration(labelText: 'Song Name*'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'Audio URL*'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (HH:MM:SS)',
                ),
              ),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Genre'),
              ),
              const SizedBox(height: 16),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _artistNames;
                  }
                  return _artistNames.where(
                    (name) => name.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    ),
                  );
                },
                onSelected: (selection) {
                  _artistController.text = selection;
                },
                fieldViewBuilder:
                    (
                      context,
                      textEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      textEditingController.text = _artistController.text;
                      textEditingController
                          .selection = TextSelection.fromPosition(
                        TextPosition(offset: textEditingController.text.length),
                      );
                      textEditingController.addListener(() {
                        _artistController.text = textEditingController.text;
                      });
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Artist Name*',
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      );
                    },
              ),
              const SizedBox(height: 20),
              if (_message.isNotEmpty)
                Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('Error')
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _addSong,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Song'),
              ),

              // ViewAsUser button
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewAsUserUsernameCheck(),
                      ),
                    );
                  },
                  child: const Text('View as User'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
