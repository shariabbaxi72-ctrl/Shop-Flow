import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../providers/notification_provider.dart';
import '../wishlist_screen.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import '../../providers/cart_provider.dart';


final currentTabProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(orderStatusWatcherProvider);

    final currentTab = ref.watch(currentTabProvider);

    final screens = [
      const HomeScreen(),
      const ExploreScreen(),
      const CartScreen(),
      const WishlistScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: screens[currentTab],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    currentIndex: currentTab,
                  ),
                  _NavItem(
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore_rounded,
                    label: 'Explore',
                    index: 1,
                    currentIndex: currentTab,
                  ),

                  // Cart — badge ke saath
                  Consumer(
                    builder: (context, ref, _) {
                      final count = ref.watch(cartItemCountProvider);
                      return GestureDetector(
                        onTap: () => ref
                            .read(currentTabProvider.notifier)
                            .state = 2,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: currentTab == 2
                                    ? const Color(0xFF6C63FF)
                                    .withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    currentTab == 2
                                        ? Icons.shopping_cart_rounded
                                        : Icons.shopping_cart_outlined,
                                    color: currentTab == 2
                                        ? const Color(0xFF6C63FF)
                                        : Colors.grey.shade400,
                                    size: 22,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Cart',
                                    style: TextStyle(
                                      color: currentTab == 2
                                          ? const Color(0xFF6C63FF)
                                          : Colors.grey.shade400,
                                      fontSize: 10,
                                      fontWeight: currentTab == 2
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (count > 0)
                              Positioned(
                                right: 6,
                                top: 0,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6584),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),

                  _NavItem(
                    icon: Icons.favorite_outline,
                    activeIcon: Icons.favorite_rounded,
                    label: 'Wishlist',
                    index: 3,
                    currentIndex: currentTab,
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    index: 4,
                    currentIndex: currentTab,
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

class _NavItem extends ConsumerWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => ref.read(currentTabProvider.notifier).state = index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6C63FF).withOpacity(0.1)
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
                  : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade400,
                fontSize: 10,
                fontWeight:
                isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}