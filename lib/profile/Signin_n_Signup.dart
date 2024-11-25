import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Email!';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid Email!';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Password!';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    return null;
  }

  Future<void> submitForm() async {
    if (formKey.currentState!.validate()) {
      final response = await http.post(
          Uri.parse('https://uda-mobile-server.onrender.com/register'),
          body: {
            'username': usernameController.text,
            'password': passwordController.text,
          }
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!'))
        );
        Navigator.pushNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed!'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Sign Up'), backgroundColor: Colors.lightBlueAccent,),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 0.2 * screenHeight,),
              const Text(
                'Create Account',
                style: TextStyle(
                    fontSize: 28,
                    color: Colors.blue
                ),
              ),
              SizedBox(height: 0.02 * screenHeight,),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (Email)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: Colors.blueAccent,),
                ),
                validator: validateEmail,
              ),
              SizedBox(height: 0.01 * screenHeight,),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.blueAccent,),
                ),
                obscureText: true,
                validator: validatePassword,
              ),
              SizedBox(height: 0.02 * screenHeight,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 0.08 * screenHeight, vertical: 0.015 * screenHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )
                ),
                onPressed: submitForm,
                child: const Text('Submit', style: TextStyle(color: Colors.white70),),
              ),
              SizedBox(height: 0.01 * screenHeight,),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    'Already have an account? Log in',
                    style: TextStyle(color: Colors.blueAccent),
                  )
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/homepage');
                  },
                  child: const Text(
                    "Return to home page",
                    style: TextStyle(color: Colors.blueAccent),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Email!';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid Email!';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Password!';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    return null;
  }

  Future<void> submitSignIn() async {
    if (formKey.currentState!.validate()) {
      final response = await http.post(
          Uri.parse('https://uda-mobile-server.onrender.com/login'),
          body: {
            'username': usernameController.text,
            'password': passwordController.text,
          }
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if(responseData['userId'] != null) {
          final userId = responseData['userId'];
          final username = responseData['username'];
          await saveUserInformation(userId, username);
        }

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Successful!'))
        );

        Navigator.pushNamed(context, '/homepage');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed!'))
        );
      }
    }
  }

  Future<void> saveUserInformation(String userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('username', username);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Log In'), backgroundColor: Colors.lightBlueAccent,),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 0.2 * screenHeight,),
              const Text(
                'Welcome Back',
                style: TextStyle(
                    fontSize: 28,
                    color: Colors.blue
                ),
              ),
              SizedBox(height: 0.02 * screenHeight,),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (Email)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: Colors.blueAccent,),
                ),
                validator: validateEmail,
              ),
              SizedBox(height: 0.01 * screenHeight,),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.blueAccent,),
                ),
                obscureText: true,
                validator: validatePassword,
              ),
              SizedBox(height: 0.02 * screenHeight,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 0.08 * screenHeight, vertical: 0.015 * screenHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )
                ),
                onPressed: submitSignIn,
                child: const Text('Submit', style: TextStyle(color: Colors.white70),),
              ),
              SizedBox(height: 0.01 * screenHeight,),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(color: Colors.blueAccent),
                  )
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/homepage');
                  },
                  child: const Text(
                    "Return to home page",
                    style: TextStyle(color: Colors.blueAccent),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}