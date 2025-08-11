import 'package:flutter/material.dart';
import 'package:koe/clients/features/auth/widgets/custom_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Signup Page',
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            CustomField(hintText: 'name'),
            const SizedBox(height: 15),
            CustomField(hintText: 'email'),
            const SizedBox(height: 15),
            CustomField(hintText: 'password'),
            const SizedBox(height: 15),
            CustomField(hintText: 'confirm password'),
          ],
        ),
      ),
    );
  }
}
