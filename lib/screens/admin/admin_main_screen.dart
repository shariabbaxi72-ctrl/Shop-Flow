import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'admin_dashboard_screen.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import '../../providers/auth_provider.dart';


final adminTabProvider = StateProvider<int>((ref) => 0);

class AdminMainScreen extends ConsumerWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(adminTabProvider);

    final screens = [
      const AdminDashboardScreen(),
      const AdminProductsScreen(),
      const AdminOrdersScreen(),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: screens[currentTab],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AdminNavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    index: 0,
                    current: currentTab,
                  ),
                  _AdminNavItem(
                    icon: Icons.inventory_2_outlined,
                    activeIcon: Icons.inventory_2_rounded,
                    label: 'Products',
                    index: 1,
                    current: currentTab,
                  ),
                  _AdminNavItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long_rounded,
                    label: 'Orders',
                    index: 2,
                    current: currentTab,
                  ),
                  // Logout
                  GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: const Text('Logout'),
                          content: const Text(
                              'Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Logout',
                                  style:
                                  TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref
                            .read(authServiceProvider)
                            .signOut();
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.logout_rounded,
                            color: Colors.red.shade400, size: 22),
                        const SizedBox(height: 2),
                        Text('Logout',
                            style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: 10,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends ConsumerWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;

  const _AdminNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () =>
      ref.read(adminTabProvider.notifier).state = index,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6C63FF).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? const Color(0xFF6C63FF)
                  : Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade600,
                fontSize: 10,
                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}