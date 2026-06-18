import 'package:flutter/material.dart';

/// Shown briefly while the auth state is resolving on startup.
///
/// Matches the native launch splash: the brand logo centered on the Gurukula
/// violet, with a subtle loading indicator.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// The Gurukula brand violet (matches the logo background and native splash).
  static const Color _brand = Color(0xFF591EE8);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _brand,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              child: Image(
                image: AssetImage('assets/logo/gurukula_logo.png'),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 28),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
