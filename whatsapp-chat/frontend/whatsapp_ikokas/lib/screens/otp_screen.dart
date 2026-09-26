import 'package:flutter/material.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String expectedOtp;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.expectedOtp,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  void _verifyOTP() {
    final enteredOtp = _otpController.text.trim();

    if (enteredOtp == widget.expectedOtp) {
      // OTP matched!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication Successful!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      // Wrong OTP
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              'Enter OTP sent to +${widget.expectedOtp}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Enter OTP sent to +${widget.phoneNumber}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: '4-digit OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Verify'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Your OTP was: ${widget.expectedOtp} (For testing)')),
                );
              },
              child: const Text('Resend OTP'),
            )
          ],
        ),
      ),
    );
  }
}
