import 'package:flutter/material.dart';
import 'package:koe/clients/features/auth/widgets/auth_gradient_button.dart';
import 'package:koe/clients/features/auth/widgets/custom_field.dart';
import 'package:koe/core/theme/app_pallete.dart';
import 'package:flutter/gestures.dart';
import 'package:koe/clients/features/auth/view/pages/login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
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
                'Sign up',
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              CustomField(hintText: 'name'),
              const SizedBox(height: 15),
              CustomField(hintText: 'email'),
              const SizedBox(height: 15),
              CustomField(hintText: 'password'),
              const SizedBox(height: 20),
              AuthGradientButton(),

              const SizedBox(height: 20),

              Container(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: Theme.of(context).textTheme.titleMedium,

                    children: [
                      TextSpan(
                        text: ' Login',

                        style: TextStyle(
                          color: Pallete.gradient1,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navigate to login page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
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
