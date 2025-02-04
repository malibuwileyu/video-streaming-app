import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;

  const HomeScreen({
    required this.authService,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.authService.signOut();
      if (mounted) {
        // Navigate to login screen
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReelAI'),
        actions: [
          _isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _handleLogout,
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to ReelAI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (user != null && user.email != null)
              Text(
                user.email!,
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
} 