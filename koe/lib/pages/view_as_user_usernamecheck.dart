import 'package:flutter/material.dart';
import 'view_as_user_homepage.dart'; // second screen
import '../backend/login.dart';                 // LoginManager with userExists()

class ViewAsUserUsernameCheck extends StatefulWidget {
  const ViewAsUserUsernameCheck({super.key});

  @override
  State<ViewAsUserUsernameCheck> createState() => _ViewAsUserUsernameCheckState();
}

class _ViewAsUserUsernameCheckState extends State<ViewAsUserUsernameCheck> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goToUserPage() async {
    if (!_formKey.currentState!.validate()) return;

    final input = _controller.text.trim();
    FocusScope.of(context).unfocus(); // dismiss keyboard
    setState(() => _isLoading = true);

    try {
      final exists = await LoginManager.userExists(input);
      if (!exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User "$input" not found')),
        );
        return;
      }

      // Navigate to the second page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewAsUserHomepage(userName: input),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View as User')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter User Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'User Name',
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _goToUserPage(),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _goToUserPage,
                child: _isLoading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}