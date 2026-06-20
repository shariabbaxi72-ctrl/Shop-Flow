import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/order_provider.dart';
import 'help_screen.dart';
import 'my_orders_screen.dart';
import 'notifications_screen.dart';


// Profile data provider
final profileNameProvider = StateProvider<String>((ref) => '');
final profileImageProvider = StateProvider<File?>((ref) => null);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profileName = ref.watch(profileNameProvider);
    final profileImage = ref.watch(profileImageProvider);
    final ordersAsync = ref.watch(userOrdersProvider);
    final wishlistCount = ref.watch(wishlistCountProvider);

    // Display name — profileName ya email se
    final displayName = profileName.isNotEmpty
        ? profileName
        : (user?.email?.split('@')[0] ?? 'User');

    // Saved addresses — orders se unique addresses
    final savedAddresses = ordersAsync.value
        ?.map((o) => '${o.address}, ${o.city}')
        .toSet()
        .toList() ??
        [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    // Profile picture
                    GestureDetector(
                      onTap: () =>
                          _showImagePicker(context, ref),
                      child: Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2.5),
                            ),
                            child: ClipOval(
                              child: profileImage != null
                                  ? Image.file(profileImage,
                                  fit: BoxFit.cover)
                                  : Center(
                                child: Text(
                                  displayName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Camera icon
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF6C63FF),
                                    width: 1.5),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats
                    Row(


                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          title: 'Orders',
                          value:
                          '${ordersAsync.value?.length ?? 0}',
                        ),
                        Container(
                            width: 1,
                            height: 30,
                            color: Colors.white24),
                        _StatItem(
                          title: 'Wishlist',
                          value: '$wishlistCount',
                        ),
                        Container(
                            width: 1,
                            height: 30,
                            color: Colors.white24),
                        _StatItem(
                          title: 'Addresses',
                          value: '${savedAddresses.length}',
                        ),
                      ],


                    ),

                    // Profile header mein Row ke actions mein
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen()),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                color: Colors.white, size: 20),
                          ),
                          if (ref.watch(unreadCountProvider) > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF6584),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${ref.watch(unreadCountProvider)}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Account section
                    _SectionTitle(title: 'Account'),
                    const SizedBox(height: 10),
                    _MenuCard(
                      items: [
                        _MenuTile(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          subtitle: displayName,
                          onTap: () => _showEditProfile(
                              context, ref, displayName),
                        ),
                        _MenuTile(
                          icon: Icons.shopping_bag_outlined,
                          title: 'My Orders',
                          subtitle:
                          '${ordersAsync.value?.length ?? 0} orders',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                const MyOrdersScreen()),
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.location_on_outlined,
                          title: 'Saved Addresses',
                          subtitle:
                          '${savedAddresses.length} saved',
                          onTap: () => _showSavedAddresses(
                              context, savedAddresses),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Preferences
                    _SectionTitle(title: 'Preferences'),
                    const SizedBox(height: 10),
                    _MenuCard(
                      items: [
                        _MenuTile(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage alerts',
                          onTap: () {},
                        ),
                        _MenuTile(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          subtitle: 'FAQ, contact us',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HelpScreen()),
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.info_outline,
                          title: 'About ShopFlow',
                          subtitle: 'Version 1.0.0',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Logout
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () =>
                            _showLogoutDialog(context, ref),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.logout_rounded,
                              color: Colors.red.shade400, size: 20),
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right,
                            color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Image picker
  void _showImagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Change Profile Photo',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 80,
                          maxWidth: 800,
                        );
                        if (image != null && ref.context.mounted) {
                          ref.read(profileImageProvider.notifier).state =
                              File(image.path);
                        }
                      } catch (e) {
                        debugPrint('Camera error: $e');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF6C63FF).withOpacity(0.2)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              color: Color(0xFF6C63FF), size: 32),
                          SizedBox(height: 8),
                          Text('Camera',
                              style: TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                          maxWidth: 800,
                        );
                        if (image != null && ref.context.mounted) {
                          ref.read(profileImageProvider.notifier).state =
                              File(image.path);
                        }
                      } catch (e) {
                        debugPrint('Gallery error: $e');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6584).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFFF6584).withOpacity(0.2)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.photo_library_outlined,
                              color: Color(0xFFFF6584), size: 32),
                          SizedBox(height: 8),
                          Text('Gallery',
                              style: TextStyle(
                                  color: Color(0xFFFF6584),
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Edit Profile dialog
  void _showEditProfile(
      BuildContext context, WidgetRef ref, String currentName) {
    final controller =
    TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter your name',
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF6C63FF)),
                  ),
                  prefixIcon: const Icon(Icons.person_outline,
                      color: Color(0xFF6C63FF)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                      ),
                      child: const Text('Cancel',
                          style:
                          TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(profileNameProvider.notifier)
                            .state = controller.text.trim();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Profile updated! ✅'),
                            backgroundColor:
                            const Color(0xFF6C63FF),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10)),
                            margin: const EdgeInsets.all(16),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                      ),
                      child: const Text('Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Saved addresses
  void _showSavedAddresses(
      BuildContext context, List<String> addresses) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Saved Addresses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 16),
            if (addresses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.location_off_outlined,
                          size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'No saved addresses yet',
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Place an order to save your address',
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...addresses.asMap().entries.map((entry) {
                final i = entry.key;
                final address = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.location_on,
                          color: Color(0xFF6C63FF), size: 18),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Logout dialog
  void _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout_rounded,
                    color: Colors.red.shade400, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Logout',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                      ),
                      child: const Text('Logout',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true) {
      await ref.read(authServiceProvider).signOut();
    }
  }
}

// Widgets
class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(title,
            style: TextStyle(
                color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E))),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuTile> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: items
            .map((item) => ListTile(
          onTap: item.onTap,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon,
                color: const Color(0xFF6C63FF), size: 20),
          ),
          title: Text(item.title,
              style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          subtitle: item.subtitle != null
              ? Text(item.subtitle!,
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12))
              : null,
          trailing: Icon(Icons.chevron_right,
              color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ))
            .toList(),
      ),
    );
  }
}

class _MenuTile {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}