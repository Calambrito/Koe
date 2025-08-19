// lib/frontend/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../backend/login.dart';
import '../backend/admin.dart';
import '../backend/listener.dart' as klistener;
import 'admin_portal.dart';
import 'user_portal.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginLoading = false;
  bool _isRegisterLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.black,
        systemNavigationBarColor: Colors.black,
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoginLoading = true);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackbar('Username and password cannot be empty.', isError: true);
      setState(() => _isLoginLoading = false);
      return;
    }

    final userId = await LoginManager.authenticate(username, password);

    if (userId != null) {
      final isAdmin = await LoginManager.isAdmin(userId);

      if (isAdmin) {
        Admin user = await Admin.create(userId);
        _showSnackbar('Login successful. Welcome, admin!', isError: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPortal(admin: user)),
        );
      } else {
        klistener.Listener user = await klistener.Listener.create(userId);
        user.loadAll();
        debugPrint(
          "loaded Loadedd loaded Loadedd loaded Loadedd loaded Loadedd loaded Loadedd loaded Loadeddloaded Loadedd",
        );
        _showSnackbar('Login successful. Welcome!', isError: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserPortal(listener: user)),
        );
      }
    } else {
      _showSnackbar('Invalid username or password.', isError: true);
    }

    setState(() => _isLoginLoading = false);
  }

  Future<void> _handleRegister() async {
    setState(() => _isRegisterLoading = true);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnackbar('Username and password cannot be empty.', isError: true);
      setState(() => _isRegisterLoading = false);
      return;
    }

    final userExists = await LoginManager.userExists(username);

    if (userExists) {
      _showSnackbar(
        'Username already taken. Please choose another.',
        isError: true,
      );
    } else {
      await LoginManager.addUser(userName: username, password: password);
      _showSnackbar(
        'Registration successful! You can now log in.',
        isError: false,
      );
      _usernameController.clear();
      _passwordController.clear();
    }

    setState(() => _isRegisterLoading = false);
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // SPACERS REMOVED FROM HERE
                      const Center(
                        child: Text(
                          'Koe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 60,
                      ), // Added for spacing below the title
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.purple,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.purple,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _isLoginLoading ? null : _handleLogin,
                        style:
                            ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ).copyWith(
                              overlayColor: MaterialStateProperty.all(
                                Colors.white.withOpacity(0.1),
                              ),
                            ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 50.0),
                            alignment: Alignment.center,
                            child: _isLoginLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'LOG IN',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: _isRegisterLoading ? null : _handleRegister,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withOpacity(0.8),
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: _isRegisterLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Register instead',
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                              ),
                      ),
                      // SPACERS REMOVED FROM HERE
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
