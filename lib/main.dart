import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopflow/screens/admin/admin_main_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/customer/main_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'ShopFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFFFF6584),
          surface: Color(0xFFF8F9FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F9FA),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
        ),
      ),
      // No back button — WillPopScope se handle
      home: authState.when(
        data: (user) {
          if (user == null) return const AuthScreen();
          return const RoleBasedHome();
        },
        loading: () => const Scaffold(
          backgroundColor: Color(0xFFF8F9FA),
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6C63FF),
            ),
          ),
        ),
        error: (_, __) => const AuthScreen(),
      ),
    );
  }
}

class RoleBasedHome extends ConsumerWidget {
  const RoleBasedHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(userRoleProvider);

    return roleAsync.when(
      data: (role) {
        if (role == 'admin') {
          return const AdminMainScreen();
        }
        return const MainScreen();;
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6C63FF),
          ),
        ),
      ),
      error: (_, __) => const AuthScreen(),
    );
  }
}

// Customer placeholder — Home Screen yahan aayegi
class CustomerPlaceholder extends ConsumerWidget {
  const CustomerPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false, // Back button band
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🛍️', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'Welcome Customer!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Home Screen coming soon...',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Admin placeholder — Admin Panel yahan aayega
class AdminPlaceholder extends ConsumerWidget {
  const AdminPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false, // Back button band
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👑', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'Admin Panel',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Admin screens coming soon...',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}