import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;
  String? _errorMessage;  // New: For displaying persistent error below form

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
      constraints: const BoxConstraints(maxWidth: 950, maxHeight: 580),
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
                      "Welcome Back to NAWASSCO Portal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Access your account to manage water services, "
                          "view bills, and make secure payments.",
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
              "Welcome Back!",
              style: TextStyle(
                fontSize: 26,
                color: Color(0xFF0D47A1),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sign in to continue",
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
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email address',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_errorMessage != null)  // New: Show persistent error message
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
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
                    : const Icon(Icons.login, color: Colors.white),
                label: Text(
                  isLoading ? 'Logging in...' : 'Login',
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
                  elevation: 3,
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading ? null : _validateAndLogin,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: isLoading ? null : () => context.go('/forgot-password'),
            child: const Text("Forgot Password?"),
          ),
          TextButton(
            onPressed: isLoading ? null : () => context.go('/register'),
            child: const Text("Create an account"),
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

  Future<void> _validateAndLogin() async {
    // Clear previous error
    // ref.read(authProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // Hide keyboard

    await ref.read(authProvider.notifier).login(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
      context,
    );
  }
}