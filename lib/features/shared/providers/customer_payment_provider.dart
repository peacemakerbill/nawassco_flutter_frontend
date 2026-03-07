import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_io/io.dart' as io;

import '../../../core/services/api_service.dart';
import '../../public/auth/providers/auth_provider.dart';
import '../models/customer_payment_model.dart';

// Payment State
class PaymentState {
  final PaymentMethod selectedPaymentMethod;
  final PaymentPurpose selectedPaymentPurpose;
  final double amount;
  final String accountNumber;
  final String phoneNumber;
  final bool isProcessing;
  final bool isLoading;
  final String? errorMessage;
  final List<PaymentTransaction> transactions;
  final SecurityInfo? securityInfo;
  final DeviceInfo? deviceInfo;

  PaymentState({
    this.selectedPaymentMethod = PaymentMethod.mpesa,
    this.selectedPaymentPurpose = PaymentPurpose.waterBill,
    this.amount = 0.0,
    this.accountNumber = '',
    this.phoneNumber = '',
    this.isProcessing = false,
    this.isLoading = false,
    this.errorMessage,
    this.transactions = const [],
    this.securityInfo,
    this.deviceInfo,
  });

  PaymentState copyWith({
    PaymentMethod? selectedPaymentMethod,
    PaymentPurpose? selectedPaymentPurpose,
    double? amount,
    String? accountNumber,
    String? phoneNumber,
    bool? isProcessing,
    bool? isLoading,
    String? errorMessage,
    List<PaymentTransaction>? transactions,
    SecurityInfo? securityInfo,
    DeviceInfo? deviceInfo,
  }) {
    return PaymentState(
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedPaymentPurpose: selectedPaymentPurpose ?? this.selectedPaymentPurpose,
      amount: amount ?? this.amount,
      accountNumber: accountNumber ?? this.accountNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isProcessing: isProcessing ?? this.isProcessing,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      transactions: transactions ?? this.transactions,
      securityInfo: securityInfo ?? this.securityInfo,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  static PaymentState initial() => PaymentState();
}

// Main Payment Notifier
class CustomerPaymentNotifier extends StateNotifier<PaymentState> {
  CustomerPaymentNotifier(this.ref) : super(PaymentState.initial()) {
    _initialize();
  }

  final Ref ref;
  StreamSubscription? _deviceInfoSubscription;

  Future<void> _initialize() async {
    await _initializeSecurityInfo();
    _loadInitialPhoneNumber();
  }

  @override
  void dispose() {
    _deviceInfoSubscription?.cancel();
    super.dispose();
  }

  // Initialize with user data from auth
  void _loadInitialPhoneNumber() {
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated && authState.user != null) {
      final userPhone = authState.user!['phoneNumber']?.toString() ?? '';
      if (userPhone.isNotEmpty) {
        state = state.copyWith(phoneNumber: _formatPhoneNumber(userPhone));
      }
    }
  }

  // Get user data from auth provider
  Map<String, dynamic>? _getUserData() {
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      return {
        'id': authState.user?['_id'] ?? authState.user?['id'],
        'firstName': authState.user?['firstName'] ?? '',
        'lastName': authState.user?['lastName'] ?? '',
        'email': authState.user?['email'] ?? '',
        'phoneNumber': authState.user?['phoneNumber'] ?? '',
        'meterNumber': authState.user?['meterNumber'],
        'sewerageServiceNumber': authState.user?['sewerageServiceNumber'],
      };
    }
    return null;
  }

  // Payment Method
  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void setPaymentPurpose(PaymentPurpose purpose) {
    state = state.copyWith(selectedPaymentPurpose: purpose);
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void setAccountNumber(String accountNumber) {
    state = state.copyWith(accountNumber: accountNumber.trim());
  }

  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(phoneNumber: _formatPhoneNumber(phoneNumber));
  }

  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Format to 254 format
    if (digits.startsWith('0')) {
      return '254${digits.substring(1)}';
    } else if (digits.startsWith('254')) {
      return digits;
    } else if (digits.length == 9) {
      return '254$digits';
    } else {
      return digits; // Return as-is if unknown format
    }
  }

  // Initialize security info automatically
  Future<void> _initializeSecurityInfo() async {
    try {
      // Get device info
      final deviceInfoPlugin = DeviceInfoPlugin();
      String deviceId = '';
      String deviceName = '';
      String deviceModel = '';
      String operatingSystem = '';

      if (io.Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id;
        deviceName = androidInfo.device;
        deviceModel = androidInfo.model;
        operatingSystem = 'Android ${androidInfo.version.release}';
      } else if (io.Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        deviceName = iosInfo.name;
        deviceModel = iosInfo.model;
        operatingSystem = 'iOS ${iosInfo.systemVersion}';
      } else {
        deviceId = 'web-${DateTime.now().millisecondsSinceEpoch}';
        deviceName = 'Web Browser';
        deviceModel = 'Web';
        operatingSystem = 'Web';
      }

      // Get app version - FIXED: Use PackageInfo.fromPlatform()
      String? appVersion;
      try {
        final packageInfo = await PackageInfo.fromPlatform(); // Fixed this line
        appVersion = packageInfo.version;
      } catch (e) {
        appVersion = '1.0.0';
      }

      final deviceInfo = DeviceInfo(
        deviceId: deviceId,
        deviceName: deviceName,
        deviceModel: deviceModel,
        operatingSystem: operatingSystem,
        appVersion: appVersion,
      );

      // Get IP address
      final ipAddress = await _getPublicIpAddress();

      // Generate device fingerprint
      final deviceFingerprint = _generateDeviceFingerprint(deviceInfo);

      // Create security info
      final securityInfo = SecurityInfo(
        ipAddress: ipAddress,
        userAgent: _getUserAgent(),
        deviceFingerprint: deviceFingerprint,
        isSuspicious: false,
        riskScore: 0,
      );

      state = state.copyWith(
        deviceInfo: deviceInfo,
        securityInfo: securityInfo,
      );

    } catch (e) {
      print('Error initializing security info: $e');
      // Fallback security info
      final securityInfo = SecurityInfo(
        ipAddress: 'unknown',
        userAgent: 'unknown',
        deviceFingerprint: 'unknown',
      );
      state = state.copyWith(securityInfo: securityInfo);
    }
  }

  Future<String> _getPublicIpAddress() async {
    try {
      // For web, we need to use different approach since http package may not work
      if (kIsWeb) {
        // For web, we can't easily get IP from client-side without a service
        return 'web-client';
      }

      // Try multiple IP services for reliability
      final services = [
        'https://api.ipify.org',
        'https://api64.ipify.org',
        'https://icanhazip.com',
      ];

      for (var service in services) {
        try {
          final dio = ref.read(dioProvider);
          final response = await dio.get(service);
          if (response.statusCode == 200) {
            return response.data.toString().trim();
          }
        } catch (e) {
          continue;
        }
      }

      // Fallback to local IP if available
      if (!kIsWeb) {
        for (var interface in await NetworkInterface.list()) {
          for (var addr in interface.addresses) {
            if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
              return addr.address;
            }
          }
        }
      }

      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  String _getUserAgent() {
    if (kIsWeb) {
      return 'Web Browser';
    } else if (io.Platform.isAndroid) {
      return 'Android App';
    } else if (io.Platform.isIOS) {
      return 'iOS App';
    } else {
      return 'Mobile App';
    }
  }

  String _generateDeviceFingerprint(DeviceInfo deviceInfo) {
    final components = [
      deviceInfo.deviceId,
      deviceInfo.deviceModel,
      deviceInfo.operatingSystem,
      io.Platform.localeName,
      DateTime.now().millisecondsSinceEpoch.toString(),
    ];

    // Create a hash of all components
    final fingerprint = components.join('|');
    return base64Encode(utf8.encode(fingerprint)).substring(0, 32);
  }

  // Calculate risk score based on payment details
  int _calculateRiskScore(double amount) {
    int riskScore = 0;

    // High amount risk
    if (amount > 50000) riskScore += 30;
    else if (amount > 20000) riskScore += 15;

    // Unusual payment time (between 12am - 5am)
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour <= 5) riskScore += 20;

    // New device risk (simplified - in real app, check device history)
    riskScore += 10;

    return riskScore.clamp(0, 100);
  }

  // Process payment
  Future<PaymentResponse> processPayment() async {
    if (state.isProcessing) {
      return PaymentResponse(
        success: false,
        message: 'Payment already in progress',
      );
    }

    // Validate inputs
    final validationError = _validateInputs();
    if (validationError != null) {
      return PaymentResponse(
        success: false,
        message: validationError,
      );
    }

    state = state.copyWith(isProcessing: true, errorMessage: null);

    try {
      // Update security info with risk assessment
      final riskScore = _calculateRiskScore(state.amount);
      final updatedSecurityInfo = SecurityInfo(
        ipAddress: state.securityInfo?.ipAddress ?? 'unknown',
        userAgent: state.securityInfo?.userAgent ?? 'unknown',
        deviceFingerprint: state.securityInfo?.deviceFingerprint ?? 'unknown',
        isSuspicious: riskScore >= 50,
        riskScore: riskScore,
      );

      // Get user data from auth
      final userData = _getUserData();
      if (userData == null) {
        throw Exception('User not authenticated');
      }

      // Create customer info from auth user
      final customer = PaymentCustomer(
        userId: userData['id'],
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        email: userData['email'],
        phoneNumber: userData['phoneNumber'],
        meterNumber: state.selectedPaymentPurpose == PaymentPurpose.waterBill
            ? state.accountNumber
            : null,
        sewerageServiceNumber: state.selectedPaymentPurpose == PaymentPurpose.sewerageBill
            ? state.accountNumber
            : null,
        isGuest: false,
      );

      // Create payer info
      final paidBy = PaidBy(
        userId: userData['id'],
        name: '${userData['firstName']} ${userData['lastName']}',
        phoneNumber: state.phoneNumber,
        email: userData['email'],
        relationship: state.phoneNumber == userData['phoneNumber'] ? 'self' : 'other',
        isGuest: false,
      );

      // Create payment data
      final paymentData = PaymentInitiationData(
        userId: userData['id'],
        customer: customer,
        paidBy: paidBy,
        paymentMethod: state.selectedPaymentMethod,
        paymentPurpose: state.selectedPaymentPurpose,
        amount: state.amount,
        accountNumber: state.accountNumber,
        securityInfo: updatedSecurityInfo,
      );

      // Call backend API using Dio
      final response = await _callPaymentApi(paymentData);

      if (response.success) {
        // Add to transaction history
        final transaction = PaymentTransaction(
          id: response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          paymentMethod: state.selectedPaymentMethod,
          paymentPurpose: state.selectedPaymentPurpose,
          amount: state.amount,
          accountNumber: state.accountNumber,
          status: PaymentStatus.pending,
          initiatedAt: DateTime.now(),
          externalReference: response.checkoutRequestID ?? response.transactionId,
        );

        final updatedTransactions = [transaction, ...state.transactions];

        state = state.copyWith(
          transactions: updatedTransactions,
          securityInfo: updatedSecurityInfo,
          isProcessing: false,
        );
      } else {
        state = state.copyWith(isProcessing: false);
      }

      return response;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      );

      return PaymentResponse(
        success: false,
        message: 'Payment failed: ${e.toString()}',
      );
    }
  }

  String? _validateInputs() {
    if (state.amount <= 0) {
      return 'Please enter a valid amount';
    }

    if (state.accountNumber.isEmpty) {
      return 'Please enter your account number';
    }

    if (state.phoneNumber.isEmpty || !state.phoneNumber.startsWith('254') || state.phoneNumber.length != 12) {
      return 'Please enter a valid phone number (e.g., 07XXXXXXXX)';
    }

    if (state.selectedPaymentPurpose == PaymentPurpose.waterBill) {
      if (!state.accountNumber.contains(RegExp(r'^[A-Z0-9]+$'))) {
        return 'Please enter a valid water service number';
      }
    } else {
      if (!state.accountNumber.contains(RegExp(r'^SEW-\d{8}-[A-Z0-9]+$'))) {
        return 'Please enter a valid sewerage service number (format: SEW-YYYYMMDD-XXXXXX)';
      }
    }

    return null;
  }

  Future<PaymentResponse> _callPaymentApi(PaymentInitiationData paymentData) async {
    try {
      final dio = ref.read(dioProvider);

      final response = await dio.post(
        '/v1/nawassco/payment/initiate',
        data: paymentData.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentResponse.fromJson(response.data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          // Server responded with error
          throw Exception('Payment failed: ${e.response?.data?['message'] ?? e.response?.statusMessage}');
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw Exception('Network timeout. Please check your connection');
        } else if (e.type == DioExceptionType.connectionError) {
          throw Exception('No internet connection');
        }
      }
      throw Exception('Payment failed: ${e.toString()}');
    }
  }

  // Load user's transaction history
  Future<void> loadTransactions() async {
    final userData = _getUserData();
    if (userData == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final dio = ref.read(dioProvider);

      final response = await dio.get(
        '/v1/nawassco/payment/user/${userData['id']}',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> transactionsJson = data['data'] ?? [];
          final transactions = transactionsJson
              .map((json) => PaymentTransaction.fromJson(json))
              .toList();

          state = state.copyWith(transactions: transactions);
        }
      }
    } catch (e) {
      print('Error loading transactions: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Retry a failed payment
  Future<PaymentResponse> retryPayment(String paymentId) async {
    state = state.copyWith(isProcessing: true);

    try {
      final dio = ref.read(dioProvider);

      final response = await dio.post(
        '/v1/nawassco/payment/retry/$paymentId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        state = state.copyWith(isProcessing: false);
        return PaymentResponse.fromJson(data);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(isProcessing: false);
      return PaymentResponse(
        success: false,
        message: 'Retry failed: ${e.toString()}',
      );
    }
  }

  // Clear all data (for logout)
  void clear() {
    final userData = _getUserData();
    final userPhone = userData?['phoneNumber']?.toString() ?? '';

    state = PaymentState(
      phoneNumber: userPhone.isNotEmpty ? _formatPhoneNumber(userPhone) : '',
    );
  }
}

// Provider definitions
final customerPaymentProvider = StateNotifierProvider<CustomerPaymentNotifier, PaymentState>(
      (ref) => CustomerPaymentNotifier(ref),
);

// Provider for auth status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

// Provider for user data
final userDataProvider = Provider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState.isAuthenticated && authState.user != null) {
    return {
      'id': authState.user!['_id'] ?? authState.user!['id'],
      'firstName': authState.user!['firstName'] ?? '',
      'lastName': authState.user!['lastName'] ?? '',
      'email': authState.user!['email'] ?? '',
      'phoneNumber': authState.user!['phoneNumber'] ?? '',
      'meterNumber': authState.user!['meterNumber'],
      'sewerageServiceNumber': authState.user!['sewerageServiceNumber'],
    };
  }
  return null;
});

// Selectors for specific state values
final selectedPaymentMethodProvider = Provider<PaymentMethod>((ref) {
  return ref.watch(customerPaymentProvider).selectedPaymentMethod;
});

final selectedPaymentPurposeProvider = Provider<PaymentPurpose>((ref) {
  return ref.watch(customerPaymentProvider).selectedPaymentPurpose;
});

final amountProvider = Provider<double>((ref) {
  return ref.watch(customerPaymentProvider).amount;
});

final accountNumberProvider = Provider<String>((ref) {
  return ref.watch(customerPaymentProvider).accountNumber;
});

final phoneNumberProvider = Provider<String>((ref) {
  return ref.watch(customerPaymentProvider).phoneNumber;
});

final isProcessingProvider = Provider<bool>((ref) {
  return ref.watch(customerPaymentProvider).isProcessing;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(customerPaymentProvider).isLoading;
});

final transactionsProvider = Provider<List<PaymentTransaction>>((ref) {
  return ref.watch(customerPaymentProvider).transactions;
});

final securityInfoProvider = Provider<SecurityInfo?>((ref) {
  return ref.watch(customerPaymentProvider).securityInfo;
});

// Computed providers
final canMakePaymentProvider = Provider<bool>((ref) {
  final state = ref.watch(customerPaymentProvider);
  return state.amount > 0 &&
      state.accountNumber.isNotEmpty &&
      state.phoneNumber.isNotEmpty &&
      !state.isProcessing;
});

final totalAmountProvider = Provider<double>((ref) {
  final state = ref.watch(customerPaymentProvider);
  final fee = state.selectedPaymentMethod == PaymentMethod.mpesa
      ? _calculateMpesaFee(state.amount)
      : 15.0;
  return state.amount + fee;
});

double _calculateMpesaFee(double amount) {
  final fee = amount * 0.01;
  return fee.clamp(10, 100).toDouble();
}