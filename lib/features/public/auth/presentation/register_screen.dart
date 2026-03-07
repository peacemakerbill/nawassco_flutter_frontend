// register_screen.dart (updated)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe8f0f7), Color(0xFFf5f7fa)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isLargeScreen
                ? _buildWideLayout(context, authState.isLoading)
                : _buildMobileLayout(context, authState.isLoading),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, bool isLoading) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 950, maxHeight: 700),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0D47A1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.water_drop, color: Colors.white, size: 80),
                    SizedBox(height: 24),
                    Text(
                      "Join NAWASCO Portal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Create an account to manage your water services, "
                          "view bills, and make payments easily.",
                      style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildFormCard(context, isLoading, withPadding: true),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isLoading) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop, color: Color(0xFF0D47A1), size: 90),
            const SizedBox(height: 16),
            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 26,
                color: Color(0xFF0D47A1),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sign up to get started",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            _buildFormCard(context, isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, bool isLoading, {bool withPadding = false}) {
    final form = Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _firstNameCtrl,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your first name';
              return null;
            },
            decoration: _inputDecoration('First Name', Icons.person),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameCtrl,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your last name';
              return null;
            },
            decoration: _inputDecoration('Last Name', Icons.person),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailCtrl,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            decoration: _inputDecoration('Email', Icons.email),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneCtrl,
            enabled: !isLoading,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your phone number';
              if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                return 'Please enter a valid international phone number';
              }
              return null;
            },
            decoration: _inputDecoration('Phone Number', Icons.phone, hintText: '+254...'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passCtrl,
            enabled: !isLoading,
            obscureText: _obscure,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              if (value.length < 8) return 'Password must be at least 8 characters';
              return null;
            },
            decoration: _inputDecoration('Password', Icons.lock, suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
              onPressed: isLoading ? null : () => setState(() => _obscure = !_obscure),
            )),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPassCtrl,
            enabled: !isLoading,
            obscureText: _obscureConfirm,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm your password';
              if (value != _passCtrl.text) return 'Passwords do not match';
              return null;
            },
            decoration: _inputDecoration('Confirm Password', Icons.lock, suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
              onPressed: isLoading ? null : () => setState(() => _obscureConfirm = !_obscureConfirm),
            )),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton.icon(
                icon: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(Icons.person_add, color: Colors.white),
                label: Text(
                  isLoading ? 'Creating Account...' : 'Register',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: isLoading ? 1 : 3,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading ? null : _register,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: isLoading ? null : () => context.go('/login'),
            child: const Text("Already have an account? Login"),
          ),
        ],
      ),
    );

    return withPadding
        ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Center(child: SingleChildScrollView(child: form)),
    )
        : form;
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffixIcon, String? hintText}) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // Hide keyboard

    final data = {
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phoneNumber': _phoneCtrl.text.trim(),
      'password': _passCtrl.text.trim(),
    };

    await ref.read(authProvider.notifier).register(data, context);
  }
}