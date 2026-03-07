import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class ConfirmEmailVerificationScreen extends ConsumerStatefulWidget {
  final String? token;

  const ConfirmEmailVerificationScreen({super.key, this.token});

  @override
  ConsumerState<ConfirmEmailVerificationScreen> createState() => _ConfirmEmailVerificationScreenState();
}

class _ConfirmEmailVerificationScreenState extends ConsumerState<ConfirmEmailVerificationScreen> {
  bool _isVerifying = true;
  bool _verificationSuccess = false;
  String _message = 'Verifying your email...';

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    try {
      if (widget.token == null || widget.token!.isEmpty) {
        setState(() {
          _isVerifying = false;
          _verificationSuccess = false;
          _message = 'Invalid verification link. Please request a new verification email.';
        });
        return;
      }

      // Call the verification API
      final auth = ref.read(authProvider.notifier);
      await auth.verifyEmail(widget.token!, context);

      setState(() {
        _isVerifying = false;
        _verificationSuccess = true;
        _message = 'Email verified successfully! Redirecting to login...';
      });

      // Redirect to login after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _verificationSuccess = false;
        _message = 'Email verification failed: ${e.toString()}. Please try requesting a new verification email.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE9F1F8), Color(0xFFD7E2EE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isVerifying)
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                    ),
                  )
                else if (_verificationSuccess)
                  Icon(Icons.verified_rounded, size: 70, color: Colors.green.shade600)
                else
                  Icon(Icons.error_outline_rounded, size: 70, color: Colors.red.shade600),

                const SizedBox(height: 24),
                Text(
                  _isVerifying ? 'Verifying Email' :
                  _verificationSuccess ? 'Verification Successful' : 'Verification Failed',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: _verificationSuccess ? Colors.green.shade800 :
                    _isVerifying ? Colors.blue.shade900 : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                if (!_isVerifying && !_verificationSuccess)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/verify-email'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Request New Verification Email'),
                    ),
                  ),
                if (!_isVerifying)
                  const SizedBox(height: 16),
                if (!_isVerifying)
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}