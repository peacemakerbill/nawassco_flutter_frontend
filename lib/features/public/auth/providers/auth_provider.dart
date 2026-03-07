import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart'; // <-- for FlutterError
import 'package:nawassco/main.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/utils/toast_utils.dart'; // <-- for scaffoldMessengerKey

class AuthState {
  final bool isAuthenticated;
  final bool isAdmin;
  final bool isSalesAgent;
  final bool isAccounts;
  final bool isManager;
  final bool isHR;
  final bool isProcurement;
  final bool isSupplier;
  final bool isTechnician;
  final bool isStoreManager;
  final bool isUser; // Regular user role
  final Map<String, dynamic>? user;
  final bool isLoading;

  AuthState({
    required this.isAuthenticated,
    this.isAdmin = false,
    this.isSalesAgent = false,
    this.isAccounts = false,
    this.isManager = false,
    this.isHR = false,
    this.isProcurement = false,
    this.isSupplier = false,
    this.isTechnician = false,
    this.isStoreManager = false,
    this.isUser = false,
    this.user,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isAdmin,
    bool? isSalesAgent,
    bool? isAccounts,
    bool? isManager,
    bool? isHR,
    bool? isProcurement,
    bool? isSupplier,
    bool? isTechnician,
    bool? isStoreManager,
    bool? isUser,
    Map<String, dynamic>? user,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isAdmin: isAdmin ?? this.isAdmin,
      isSalesAgent: isSalesAgent ?? this.isSalesAgent,
      isAccounts: isAccounts ?? this.isAccounts,
      isManager: isManager ?? this.isManager,
      isHR: isHR ?? this.isHR,
      isProcurement: isProcurement ?? this.isProcurement,
      isSupplier: isSupplier ?? this.isSupplier,
      isTechnician: isTechnician ?? this.isTechnician,
      isStoreManager: isStoreManager ?? this.isStoreManager,
      isUser: isUser ?? this.isUser,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Helper method to check if user has any of the specified roles
  bool hasAnyRole(List<String> roles) {
    for (final role in roles) {
      switch (role) {
        case 'Admin':
          if (isAdmin) return true;
          break;
        case 'SalesAgent':
          if (isSalesAgent) return true;
          break;
        case 'Accounts':
          if (isAccounts) return true;
          break;
        case 'Manager':
          if (isManager) return true;
          break;
        case 'HR':
          if (isHR) return true;
          break;
        case 'Procurement':
          if (isProcurement) return true;
          break;
        case 'Supplier':
          if (isSupplier) return true;
          break;
        case 'Technician':
          if (isTechnician) return true;
          break;
        case 'StoreManager':
          if (isStoreManager) return true;
          break;
        case 'User':
          if (isUser) return true;
          break;
      }
    }
    return false;
  }

  // Helper method to get all active roles
  List<String> get activeRoles {
    final roles = <String>[];
    if (isAdmin) roles.add('Admin');
    if (isSalesAgent) roles.add('SalesAgent');
    if (isAccounts) roles.add('Accounts');
    if (isManager) roles.add('Manager');
    if (isHR) roles.add('HR');
    if (isProcurement) roles.add('Procurement');
    if (isSupplier) roles.add('Supplier');
    if (isTechnician) roles.add('Technician');
    if (isStoreManager) roles.add('StoreManager');
    if (isUser) roles.add('User');
    return roles;
  }

  // Helper method to check if user has a specific role
  bool hasRole(String role) {
    switch (role) {
      case 'Admin':
        return isAdmin;
      case 'SalesAgent':
        return isSalesAgent;
      case 'Accounts':
        return isAccounts;
      case 'Manager':
        return isManager;
      case 'HR':
        return isHR;
      case 'Procurement':
        return isProcurement;
      case 'Supplier':
        return isSupplier;
      case 'Technician':
        return isTechnician;
      case 'StoreManager':
        return isStoreManager;
      case 'User':
        return isUser;
      default:
        return false;
    }
  }
}

class AuthProvider extends StateNotifier<AuthState> {
  final Dio dio;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  AuthProvider(this.dio, this.scaffoldMessengerKey)
      : super(AuthState(isAuthenticated: false));

  bool get isMounted => mounted;

  // -----------------------------------------------------------------
  // LOGIN
  // -----------------------------------------------------------------
  Future<void> login(String email, String password, BuildContext context) async {
    final goRouter = GoRouter.of(context); // Capture early – safe for async

    try {
      state = state.copyWith(isLoading: true);
      print('Attempting login for: $email');

      final response = await dio.post('/auth/login', data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      print('Login response received: ${response.data}');

      if (response.data['success'] == true) {
        final user = response.data['user'];
        final token = response.data['token'];
        final roles = (user['roles'] as List).cast<String>();

        print('Login successful. User roles: $roles');

        if (kIsWeb && token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt', token);
        }

        state = AuthState(
          isAuthenticated: true,
          isAdmin: roles.contains('Admin'),
          isSalesAgent: roles.contains('SalesAgent'),
          isAccounts: roles.contains('Accounts'),
          isManager: roles.contains('Manager'),
          isHR: roles.contains('HR'),
          isProcurement: roles.contains('Procurement'),
          isSupplier: roles.contains('Supplier'),
          isTechnician: roles.contains('Technician'),
          isStoreManager: roles.contains('StoreManager'),
          isUser: roles.contains('User'),
          user: user,
        );

        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Welcome back! Login successful.',
            key: scaffoldMessengerKey,
          );
        });

        _redirectWithRouter(goRouter, roles);
      } else {
        final errorMessage = response.data['message'] ?? 'Login failed. Please try again.';
        print('Login failed with message: $errorMessage');
        _showToastSafely(() {
          ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        });
      }
    } catch (e) {
      print('Login caught exception: $e');
      _handleError(e);
    } finally {
      if (isMounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  // -----------------------------------------------------------------
  // REGISTER
  // -----------------------------------------------------------------
  Future<void> register(Map<String, dynamic> data, BuildContext context) async {
    final goRouter = GoRouter.of(context); // Capture early

    try {
      state = state.copyWith(isLoading: true);
      print('Attempting registration for: ${data['email']}');

      final registrationData = {
        'firstName': data['firstName']?.toString().trim(),
        'lastName': data['lastName']?.toString().trim(),
        'email': data['email']?.toString().trim().toLowerCase(),
        'phoneNumber': data['phoneNumber']?.toString().trim(),
        'password': data['password']?.toString(),
      };

      final response = await dio.post('/auth/register', data: registrationData);

      print('Registration response received: ${response.data}');

      if (response.data['success'] == true) {
        final email = data['email']?.toString().trim();

        print('Registration successful for: $email');

        _showToastSafely(() {
          ToastUtils.showSuccessToast(
            'Registration successful! Please check your email for verification instructions.',
            key: scaffoldMessengerKey,
          );
        });

        if (isMounted) {
          final uri = Uri(
            path: '/verify-email',
            queryParameters: {'email': email},
          );
          goRouter.go(uri.toString());
        }
      } else {
        final errorMessage = response.data['message'] ?? 'Registration failed. Please try again.';
        print('Registration failed with message: $errorMessage');
        _showToastSafely(() {
          ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        });
      }
    } catch (e) {
      print('Registration caught exception: $e');
      _handleError(e);
    } finally {
      if (isMounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  // -----------------------------------------------------------------
  // LOGOUT
  // -----------------------------------------------------------------
  Future<void> logout(BuildContext context) async {
    final goRouter = GoRouter.of(context); // Capture early

    try {
      state = state.copyWith(isLoading: true);
      print('Attempting logout');

      await dio.post('/auth/logout');
      print('Logout API call successful');
    } catch (e) {
      print('Logout API call failed: $e');
    }

    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('jwt');
        print('Web JWT cleared');
      } catch (e) {
        print('Failed to clear web JWT: $e');
      }
    }

    state = AuthState(isAuthenticated: false);
    print('Auth state reset to unauthenticated');

    if (isMounted) {
      _showToastSafely(() {
        ToastUtils.showSuccessToast('Logged out successfully', key: scaffoldMessengerKey);
      });
      goRouter.go('/login');
    }
  }

  // -----------------------------------------------------------------
  // FORGOT PASSWORD
  // -----------------------------------------------------------------
  Future<void> forgotPassword(String email, BuildContext context) async {
    try {
      state = state.copyWith(isLoading: true);
      print('Attempting password reset for: $email');

      final response = await dio.post('/auth/forgot-password', data: {
        'email': email.trim().toLowerCase(),
      });

      print('Forgot password response received: ${response.data}');

      if (response.data['success'] == true) {
        print('Password reset email sent to: $email');
        _showToastSafely(() {
          ToastUtils.showSuccessToast(
              'Password reset link sent! Please check your email.',
              key: scaffoldMessengerKey);
        });
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to send reset link. Please try again.';
        print('Forgot password failed with message: $errorMessage');
        _showToastSafely(() {
          ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        });
      }
    } catch (e) {
      print('Forgot password caught exception: $e');
      _handleError(e);
    } finally {
      if (isMounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  // -----------------------------------------------------------------
  // RESET PASSWORD
  // -----------------------------------------------------------------
  Future<void> resetPassword(String token, String password, BuildContext context) async {
    final goRouter = GoRouter.of(context); // Capture early

    try {
      state = state.copyWith(isLoading: true);
      print('Attempting password reset with token');

      final response = await dio.post('/auth/reset-password', data: {
        'token': token,
        'password': password,
      });

      print('Reset password response received: ${response.data}');

      if (response.data['success'] == true) {
        print('Password reset successful');
        _showToastSafely(() {
          ToastUtils.showSuccessToast('Password reset successful!', key: scaffoldMessengerKey);
        });

        if (isMounted) {
          goRouter.go('/login');
        }
      } else {
        final errorMessage =
            response.data['message'] ?? 'Password reset failed. Please try again.';
        print('Reset password failed with message: $errorMessage');
        _showToastSafely(() {
          ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        });
      }
    } catch (e) {
      print('Reset password caught exception: $e');
      _handleError(e);
    } finally {
      if (isMounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  // -----------------------------------------------------------------
  // VERIFY EMAIL
  // -----------------------------------------------------------------
  Future<void> verifyEmail(String token, BuildContext context) async {
    try {
      print('Attempting email verification with token');

      final response = await dio.get('/auth/verify-email', queryParameters: {
        'token': token,
      });

      print('Verify email response received: ${response.data}');

      if (response.data['success'] == true) {
        print('Email verification successful');
        _showToastSafely(() {
          ToastUtils.showSuccessToast('Email verified successfully!', key: scaffoldMessengerKey);
        });
      } else {
        final errorMessage = response.data['message'] ?? 'Email verification failed.';
        print('Email verification failed with message: $errorMessage');
        _showToastSafely(() {
          ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        });
      }
    } catch (e) {
      print('Email verification caught exception: $e');
      _handleError(e);
    }
  }

  // -----------------------------------------------------------------
  // RESEND VERIFICATION EMAIL
  // -----------------------------------------------------------------
  Future<void> resendVerificationEmail(String email, BuildContext context) async {
    try {
      print('Attempting to resend verification email to: $email');

      final response = await dio.post('/auth/resend-verification', data: {
        'email': email.trim().toLowerCase(),
      });

      print('Resend verification response received: ${response.data}');

      if (response.data['success'] == true) {
        print('Verification email resent to: $email');
        _showToastSafely(() {
          ToastUtils.showSuccessToast(
              'Verification email sent! Please check your inbox.',
              key: scaffoldMessengerKey);
        });
      } else {
        final errorMessage =
            response.data['message'] ?? 'Failed to send verification email.';
        print('Resend verification failed with message: $errorMessage');
        _showToastSafely(() {
          ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
        });
      }
    } catch (e) {
      print('Resend verification caught exception: $e');
      _handleError(e);
    }
  }

  // -----------------------------------------------------------------
  // PRIVATE HELPERS
  // -----------------------------------------------------------------
  void _redirectWithRouter(GoRouter router, List<String> roles) {
    if (!isMounted) return;

    String route = '/dashboard';

    // Define route priorities (more specific roles first)
    if (roles.contains('Admin')) {
      route = '/admin';
    } else if (roles.contains('Manager')) {
      route = '/manager';
    } else if (roles.contains('StoreManager')) {
      route = '/store-manager';
    } else if (roles.contains('SalesAgent')) {
      route = '/sales';
    } else if (roles.contains('Accounts')) {
      route = '/accounts';
    } else if (roles.contains('HR')) {
      route = '/hr';
    } else if (roles.contains('Procurement')) {
      route = '/procurement';
    } else if (roles.contains('Supplier')) {
      route = '/supplier';
    } else if (roles.contains('Technician')) {
      route = '/technician';
    } else if (roles.contains('User')) {
      route = '/dashboard';
    }

    print('Redirecting to: $route');
    router.go(route);
  }

  void _showToastSafely(VoidCallback showToast) {
    showToast();
  }

  void _handleError(dynamic error) {
    // --- NEW: Ignore internal Flutter widget errors ---
    if (error is FlutterError && error.message.contains('deactivated widget')) {
      print('Ignored deactivated widget error: $error');
      return;
    }

    print('=== ERROR HANDLER TRIGGERED ===');
    print('Error type: ${error.runtimeType}');
    print('Error: $error');

    String errorMessage = 'An unexpected error occurred. Please try again.';

    if (error is DioException) {
      print('DioException type: ${error.type}');
      print('Response: ${error.response}');
      print('Response data: ${error.response?.data}');
      print('Response status: ${error.response?.statusCode}');

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Request timed out. Please check your internet connection.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection. Please check your network.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          if (data is Map<String, dynamic>) {
            if (data['error'] is String && (data['error'] as String).isNotEmpty) {
              errorMessage = data['error'];
            } else if (data['message'] is String &&
                (data['message'] as String).isNotEmpty) {
              errorMessage = data['message'];
            } else if (data['error'] is Map<String, dynamic>) {
              final nestedError = data['error'];
              if (nestedError['message'] is String &&
                  (nestedError['message'] as String).isNotEmpty) {
                errorMessage = nestedError['message'];
              }
            } else if (statusCode == 401) {
              errorMessage = 'Invalid email or password.';
            } else if (statusCode == 403) {
              errorMessage = 'Access denied. Please verify your account.';
            } else {
              errorMessage = _getErrorMessageFromStatusCode(statusCode);
            }
          } else if (data is String && data.isNotEmpty) {
            errorMessage = data;
          } else {
            errorMessage = _getErrorMessageFromStatusCode(statusCode);
          }
          break;
        case DioExceptionType.unknown:
          if (error.error?.toString().contains('SocketException') == true) {
            errorMessage = 'No internet connection. Please check your network.';
          } else if (error.error?.toString().contains('HandshakeException') ==
              true) {
            errorMessage = 'Secure connection failed. Please try again.';
          }
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'Security certificate error. Please try again.';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request was cancelled.';
          break;
        default:
          errorMessage = 'An unexpected error occurred. Please try again.';
      }
    } else if (error is String) {
      errorMessage = error;
    } else if (error is FormatException) {
      errorMessage = 'Data format error. Please try again.';
    } else if (error is TypeError) {
      errorMessage = 'Unexpected data received. Please try again.';
    }

    print('Final Error Message: $errorMessage');

    _showToastSafely(() {
      ToastUtils.showErrorToast(errorMessage, key: scaffoldMessengerKey);
    });
  }

  String _getErrorMessageFromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Invalid email or password. Please check your credentials.';
      case 403:
        return 'Access denied. Please verify your email or contact support.';
      case 404:
        return 'Account not found. Please check your email address.';
      case 409:
        return 'Account already exists with this email.';
      case 422:
        return 'Invalid input data. Please check your information.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Service temporarily unavailable.';
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again.';
      default:
        if (statusCode != null && statusCode >= 500) {
          return 'Server error. Please try again later.';
        } else if (statusCode != null && statusCode >= 400) {
          return 'Request failed. Please check your input and try again.';
        } else {
          return 'Something went wrong. Please try again.';
        }
    }
  }
}

// ---------------------------------------------------------------
// PROVIDER WITH GLOBAL KEY
// ---------------------------------------------------------------
final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  final dio = ref.read(dioProvider);
  return AuthProvider(dio, scaffoldMessengerKey);
});