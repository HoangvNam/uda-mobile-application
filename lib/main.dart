import 'package:flutter/material.dart';
import 'profile/Signin_n_Signup.dart';
import 'home/HomePage.dart';



void main() {
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Music Application",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SignInScreen(),
      routes: {
        '/homepage': (context) => const HomePage(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const SignInScreen(),
      },
    );
  }
}