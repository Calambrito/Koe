import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'admin_page.dart';
import 'user_home.dart';
import '../backend/login.dart'; // Import your backend

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userId = await LoginManager.authenticate(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (userId != null) {
        final isAdmin = await LoginManager.isAdmin(userId);
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isAdmin 
                ? AdminPage(userId: userId)
                : UserHome(userId: userId),
          ),
        );
      } else {
        setState(() => _errorMessage = 'Invalid credentials');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Login failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Koe',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Sign In'),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                ),
                child: const Text('Create New Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}