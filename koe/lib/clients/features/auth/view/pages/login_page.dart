import 'package:flutter/material.dart';
import 'package:koe/clients/features/auth/widgets/auth_gradient_button.dart';
import 'package:koe/clients/features/auth/widgets/custom_field.dart';
import 'package:koe/core/theme/app_pallete.dart';
import 'package:flutter/gestures.dart';
import 'package:koe/clients/features/auth/view/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              CustomField(hintText: 'email'),
              const SizedBox(height: 15),
              CustomField(hintText: 'password'),
              const SizedBox(height: 20),
              AuthGradientButton(),

              const SizedBox(height: 20),

              Container(
                child: RichText(
                  text: TextSpan(
                    text: 'Don\'t have an account? ',
                    style: Theme.of(context).textTheme.titleMedium,

                    children: [
                      TextSpan(
                        text: ' Sign up',

                        style: TextStyle(
                          color: Pallete.gradient1,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to signup page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupPage(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
