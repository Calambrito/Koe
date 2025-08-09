// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import '../backend/login.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final username = _userController.text.trim();
    final password = _passController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Please provide username and password';
      });
      return;
    }

    try {
      final userId = await LoginManager.authenticate(username, password);
      if (userId == null) {
        setState(() {
          _error = 'Invalid credentials';
          _loading = false;
        });
        return;
      }

      final isAdmin = await LoginManager.isAdmin(userId);
      setState(() => _loading = false);

      if (isAdmin) {
        // route to admin
        Navigator.of(context).pushReplacementNamed('/admin', arguments: {
          'userId': userId,
          'username': username,
        });
      } else {
        // route to user home, pass user id
        Navigator.of(context).pushReplacementNamed('/home', arguments: {
          'userId': userId,
          'username': username,
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final larges = TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white);
    final labelStyle = TextStyle(fontSize: 18, color: Colors.white70);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Koe', style: larges),
              SizedBox(height: 8),
              Text('Ask for username & password', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 28),
              TextField(
                controller: _userController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: labelStyle,
                  filled: true,
                  fillColor: Color(0xFF101214),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: labelStyle,
                  filled: true,
                  fillColor: Color(0xFF101214),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 18),
              if (_error != null)
                Text(_error!, style: TextStyle(color: Colors.redAccent)),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading ? CircularProgressIndicator() : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Text('Login', style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  // quick signup helper: create user if not exists
                  final username = _userController.text.trim();
                  final password = _passController.text;
                  if (username.isEmpty || password.isEmpty) {
                    setState(() => _error = 'Enter username & password to register');
                    return;
                  }
                  try {
                    await LoginManager.addUser(userName: username, password: password, isAdmin: false);
                    setState(() => _error = 'User created. Try logging in.');
                  } catch (e) {
                    setState(() => _error = e.toString());
                  }
                },
                child: Text('Register (quick)'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
