import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'channel_list_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController _authController = AuthController();

  bool _isLoading = false;

  void _onSuccess() {
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ChannelListView()),
    );
  }

  void _onError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _login() {
    setState(() => _isLoading = true);
    _authController.loginWithOAuth(_onSuccess, _onError);
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login to Slack')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.forum, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text('Welcome to Slack Client', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey),
                ),
                icon: const Icon(Icons.login, color: Colors.blue),
                label: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text('Sign in with Slack', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: _isLoading ? null : _login,
              ),
              const SizedBox(height: 16),
             
            ],
          ),
        ),
      ),
    );
  }
}
