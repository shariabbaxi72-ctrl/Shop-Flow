// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/auth_provider.dart';
//
// class AuthScreen extends ConsumerStatefulWidget {
//   const AuthScreen({super.key});
//
//   @override
//   ConsumerState<AuthScreen> createState() => _AuthScreenState();
// }
//
// class _AuthScreenState extends ConsumerState<AuthScreen>
//     with SingleTickerProviderStateMixin {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//
//   bool _isLogin = true;
//   bool _isLoading = false;
//   bool _showPassword = false;
//   bool _showConfirmPassword = false;
//
//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;
//
//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 350),
//     );
//     _fadeAnim = CurvedAnimation(
//         parent: _animController, curve: Curves.easeInOut);
//     _animController.forward();
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }
//
//   void _toggleMode() {
//     _animController.reset();
//     setState(() => _isLogin = !_isLogin);
//     _animController.forward();
//   }
//
//   String _parseError(String error) {
//     if (error.contains('user-not-found')) return 'No account found with this email';
//     if (error.contains('wrong-password') || error.contains('invalid-credential')) return 'Incorrect password. Please try again';
//     if (error.contains('email-already-in-use')) return 'This email is already registered';
//     if (error.contains('invalid-email')) return 'Please enter a valid email address';
//     if (error.contains('weak-password')) return 'Password too weak. Use 6+ characters';
//     if (error.contains('too-many-requests')) return 'Too many attempts. Try again later';
//     return 'Something went wrong. Try again';
//   }
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 64,
//                 height: 64,
//                 decoration: BoxDecoration(
//                   color: Colors.red.shade50,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.error_outline_rounded,
//                     color: Colors.red.shade400, size: 36),
//               ),
//               const SizedBox(height: 16),
//               const Text('Oops!',
//                   style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF1A1A2E))),
//               const SizedBox(height: 8),
//               Text(message,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.grey, fontSize: 14)),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red.shade400,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   child: const Text('Try Again',
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         child: Padding(
//           padding: const EdgeInsets.all(28),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 72,
//                 height: 72,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFEEEBFF),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.check_circle_rounded,
//                     color: Color(0xFF6C63FF), size: 40),
//               ),
//               const SizedBox(height: 20),
//               const Text('Account Created! 🎉',
//                   style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF1A1A2E))),
//               const SizedBox(height: 8),
//               const Text(
//                 'Welcome to ShopFlow!\nPlease sign in to continue.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey, fontSize: 14),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     if (mounted) setState(() => _isLogin = true);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF6C63FF),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14)),
//                   ),
//                   child: const Text('Sign In Now',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showSnackbar(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle_outline,
//                 color: Colors.white, size: 20),
//             const SizedBox(width: 8),
//             Expanded(child: Text(msg)),
//           ],
//         ),
//         backgroundColor: const Color(0xFF6C63FF),
//         behavior: SnackBarBehavior.floating,
//         shape:
//         RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }
//
//   Future<void> _submit() async {
//     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//       _showErrorDialog('Please fill all fields');
//       return;
//     }
//     if (!_isLogin &&
//         _passwordController.text != _confirmPasswordController.text) {
//       _showErrorDialog('Passwords do not match');
//       return;
//     }
//     if (!_isLogin && _passwordController.text.length < 6) {
//       _showErrorDialog('Password must be at least 6 characters');
//       return;
//     }
//
//     setState(() => _isLoading = true);
//     try {
//       final auth = ref.read(authServiceProvider);
//       if (_isLogin) {
//         await auth.signIn(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );
//       } else {
//         await auth.signUp(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );
//         await auth.signOut();
//         if (mounted) _showSuccessDialog();
//       }
//     } catch (e) {
//       if (mounted) _showErrorDialog(_parseError(e.toString()));
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _forgotPassword() async {
//     if (_emailController.text.isEmpty) {
//       _showErrorDialog('Enter your email first');
//       return;
//     }
//     try {
//       await ref
//           .read(authServiceProvider)
//           .resetPassword(email: _emailController.text.trim());
//       if (mounted) _showSnackbar('Reset link sent! Check your email 📧');
//     } catch (e) {
//       if (mounted) _showErrorDialog('Error sending reset email');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: FadeTransition(
//             opacity: _fadeAnim,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 40),
//
//                 // Logo
//                 Row(
//                   children: [
//                     Container(
//                       width: 52,
//                       height: 52,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF6C63FF),
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       child: const Center(
//                           child:
//                           Text('🛍️', style: TextStyle(fontSize: 26))),
//                     ),
//                     const SizedBox(width: 12),
//                     const Text('ShopFlow',
//                         style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF6C63FF))),
//                   ],
//                 ),
//
//                 const SizedBox(height: 36),
//
//                 Text(
//                   _isLogin ? 'Welcome\nBack! 👋' : 'Create\nAccount ✨',
//                   style: const TextStyle(
//                       fontSize: 34,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF1A1A2E),
//                       height: 1.2),
//                 ),
//
//                 const SizedBox(height: 8),
//                 Text(
//                   _isLogin
//                       ? 'Sign in to continue shopping'
//                       : 'Join ShopFlow today',
//                   style: const TextStyle(color: Colors.grey, fontSize: 15),
//                 ),
//
//                 const SizedBox(height: 32),
//
//                 // Email field
//                 _buildTextField(
//                   controller: _emailController,
//                   hint: 'Email address',
//                   icon: Icons.email_outlined,
//                   isPassword: false,
//                 ),
//
//                 const SizedBox(height: 14),
//
//                 // Password field
//                 _buildTextField(
//                   controller: _passwordController,
//                   hint: 'Password',
//                   icon: Icons.lock_outline,
//                   isPassword: true,
//                   showToggle: true,
//                   isVisible: _showPassword,
//                   onToggle: () =>
//                       setState(() => _showPassword = !_showPassword),
//                 ),
//
//                 // Confirm password — signup only
//                 if (!_isLogin) ...[
//                   const SizedBox(height: 14),
//                   _buildTextField(
//                     controller: _confirmPasswordController,
//                     hint: 'Confirm Password',
//                     icon: Icons.lock_outline,
//                     isPassword: true,
//                     showToggle: true,
//                     isVisible: _showConfirmPassword,
//                     onToggle: () => setState(() =>
//                     _showConfirmPassword = !_showConfirmPassword),
//                   ),
//                 ],
//
//                 // Forgot password — login only
//                 if (_isLogin) ...[
//                   const SizedBox(height: 8),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: GestureDetector(
//                       onTap: _forgotPassword,
//                       child: const Text(
//                         'Forgot Password?',
//                         style: TextStyle(
//                             color: Color(0xFF6C63FF),
//                             fontWeight: FontWeight.w600,
//                             fontSize: 13),
//                       ),
//                     ),
//                   ),
//                 ],
//
//                 const SizedBox(height: 28),
//
//                 // Submit button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 54,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _submit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF6C63FF),
//                       disabledBackgroundColor:
//                       const Color(0xFF6C63FF).withOpacity(0.6),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14)),
//                       elevation: 0,
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                         width: 22,
//                         height: 22,
//                         child: CircularProgressIndicator(
//                             color: Colors.white, strokeWidth: 2))
//                         : Text(
//                         _isLogin ? 'Sign In' : 'Create Account',
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Toggle login/signup
//                 Center(
//                   child: GestureDetector(
//                     onTap: _toggleMode,
//                     child: RichText(
//                       text: TextSpan(
//                         text: _isLogin
//                             ? "Don't have an account? "
//                             : 'Already have an account? ',
//                         style: const TextStyle(
//                             color: Colors.grey, fontSize: 14),
//                         children: [
//                           TextSpan(
//                             text: _isLogin ? 'Sign Up' : 'Sign In',
//                             style: const TextStyle(
//                                 color: Color(0xFF6C63FF),
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 14),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     required bool isPassword,
//     bool showToggle = false,
//     bool isVisible = false,
//     VoidCallback? onToggle,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword && !isVisible,
//       keyboardType: isPassword
//           ? TextInputType.visiblePassword
//           : TextInputType.emailAddress,
//       style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 15),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
//         prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
//         suffixIcon: showToggle
//             ? IconButton(
//             onPressed: onToggle,
//             icon: Icon(
//                 isVisible ? Icons.visibility_off : Icons.visibility,
//                 color: Colors.grey.shade400,
//                 size: 20))
//             : null,
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: BorderSide.none),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: BorderSide(color: Colors.grey.shade200)),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide:
//             const BorderSide(color: Color(0xFF6C63FF), width: 1.5)),
//         contentPadding:
//         const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _animController.reset();
    setState(() => _isLogin = !_isLogin);
    _animController.forward();
  }

  String _parseError(String error) {
    if (error.contains('user-not-found')) return 'No account found with this email';
    if (error.contains('wrong-password') || error.contains('invalid-credential')) return 'Incorrect password. Please try again';
    if (error.contains('email-already-in-use')) return 'This email is already registered';
    if (error.contains('invalid-email')) return 'Please enter a valid email address';
    if (error.contains('weak-password')) return 'Password too weak. Use 6+ characters';
    if (error.contains('too-many-requests')) return 'Too many attempts. Try again later';
    return 'Something went wrong. Try again';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDF0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.priority_high_rounded,
                    color: Color(0xFFE94560), size: 32),
              ),
              const SizedBox(height: 18),
              const Text('Something went wrong',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF14132A))),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF8E8AA3), fontSize: 14, height: 1.4)),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14132A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('Got it',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFFFF8E6E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 40),
              ),
              const SizedBox(height: 22),
              const Text('You\'re all set',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF14132A))),
              const SizedBox(height: 8),
              const Text(
                'Your account is ready. Sign in to\nstart exploring ShopFlow.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8E8AA3), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (mounted) setState(() => _isLogin = true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14132A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Sign in now',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mark_email_read_outlined,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: const Color(0xFF14132A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please fill in both fields to continue');
      return;
    }
    if (!_isLogin &&
        _passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }
    if (!_isLogin && _passwordController.text.length < 6) {
      _showErrorDialog('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authServiceProvider);
      if (_isLogin) {
        await auth.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        await auth.signOut();
        if (mounted) _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) _showErrorDialog(_parseError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      _showErrorDialog('Enter your email address first');
      return;
    }
    try {
      await ref
          .read(authServiceProvider)
          .resetPassword(email: _emailController.text.trim());
      if (mounted) _showSnackbar('Reset link sent — check your inbox');
    } catch (e) {
      if (mounted) _showErrorDialog('Could not send reset email. Try again');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF14132A),
      body: Stack(
        children: [
          // ── Gradient hero backdrop ──
          Container(
            height: screenHeight * 0.42,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFFF6B9D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Decorative floating circles
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: -50,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          // ── Header content ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Center(
                          child: Text('🛍️', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'ShopFlow',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 44),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _isLogin ? 'Welcome back' : 'Join the flow',
                      key: ValueKey(_isLogin),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? 'Your cart missed you'
                        : 'Curated drops, your style',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Floating glass form card ──
          Positioned(
            top: screenHeight * 0.30,
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F8FC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Segmented toggle — Sign in / Sign up
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEBF7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _SegmentTab(
                                  label: 'Sign In',
                                  isActive: _isLogin,
                                  onTap: () {
                                    if (!_isLogin) _toggleMode();
                                  },
                                ),
                              ),
                              Expanded(
                                child: _SegmentTab(
                                  label: 'Sign Up',
                                  isActive: !_isLogin,
                                  onTap: () {
                                    if (_isLogin) _toggleMode();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 26),

                        _FieldLabel('Email'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _emailController,
                          hint: 'Enter Email',
                          icon: Icons.alternate_email_rounded,
                          isPassword: false,
                        ),

                        const SizedBox(height: 18),

                        _FieldLabel('Password'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Enter Passowrd',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          showToggle: true,
                          isVisible: _showPassword,
                          onToggle: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),

                        if (!_isLogin) ...[
                          const SizedBox(height: 18),
                          _FieldLabel('Confirm password'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            showToggle: true,
                            isVisible: _showConfirmPassword,
                            onToggle: () => setState(() =>
                            _showConfirmPassword = !_showConfirmPassword),
                          ),
                        ],

                        if (_isLogin) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _forgotPassword,
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: Color(0xFF6C5CE7),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Gradient submit button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: _isLoading
                                  ? null
                                  : const LinearGradient(
                                colors: [
                                  Color(0xFF6C5CE7),
                                  Color(0xFFFF6B9D)
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              color: _isLoading
                                  ? const Color(0xFF6C5CE7).withOpacity(0.5)
                                  : null,
                              boxShadow: _isLoading
                                  ? []
                                  : [
                                BoxShadow(
                                  color: const Color(0xFF6C5CE7)
                                      .withOpacity(0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: _isLoading ? null : _submit,
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.4),
                                  )
                                      : Text(
                                    _isLogin
                                        ? 'Sign In'
                                        : 'Create Account',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Center(
                          child: GestureDetector(
                            onTap: _toggleMode,
                            child: RichText(
                              text: TextSpan(
                                text: _isLogin
                                    ? "New here? "
                                    : 'Already shopping with us? ',
                                style: const TextStyle(
                                    color: Color(0xFF8E8AA3), fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: _isLogin
                                        ? 'Create an account'
                                        : 'Sign in',
                                    style: const TextStyle(
                                      color: Color(0xFF6C5CE7),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isPassword,
    bool showToggle = false,
    bool isVisible = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5E2F4)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        keyboardType: isPassword
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
        style: const TextStyle(
            color: Color(0xFF14132A),
            fontSize: 15,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
          suffixIcon: showToggle
              ? IconButton(
            onPressed: onToggle,
            icon: Icon(
              isVisible
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          )
              : null,
          filled: false,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
            isActive ? const Color(0xFF14132A) : const Color(0xFF8E8AA3),
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF14132A),
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}