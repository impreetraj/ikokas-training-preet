import 'package:flutter/material.dart';
import 'views/login_view.dart';

void main() {
  runApp(const SlackApp());
}

class SlackApp extends StatelessWidget {
  const SlackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Slack MVC App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const LoginView(),
    );
  }
}
