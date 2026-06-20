import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import 'customer/main_screen.dart';
import 'auth_screen.dart';
import 'admin/admin_main_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // FirebaseAuth se directly current user lo — sabse reliable
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _go(const AuthScreen());
      return;
    }

    final role =
    await ref.read(firestoreServiceProvider).getUserRole(user.uid);

    if (!mounted) return;
    _go(role == 'admin'
        ? const AdminMainScreen()
        : const MainScreen());
  }

  void _go(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF4A90D9)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2),
                      ),
                      child: const Center(
                        child:
                        Text('🛍️', style: TextStyle(fontSize: 52)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'ShopFlow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shop Smarter, Live Better',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 60),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.7),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}