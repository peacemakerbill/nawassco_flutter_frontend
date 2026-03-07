import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/customer_payment_provider.dart';
import '../../../../models/customer_payment_model.dart';
import '../../../sub_widgets/customer_payment/payment_method_tabs.dart';
import '../../../sub_widgets/customer_payment/payment_processing_dialog.dart';
import '../../../sub_widgets/customer_payment/payment_purpose_selector.dart';
import '../../../sub_widgets/customer_payment/payment_summary_card.dart';

class PaymentContent extends ConsumerStatefulWidget {
  const PaymentContent({Key? key}) : super(key: key);

  @override
  _PaymentContentState createState() => _PaymentContentState();
}

class _PaymentContentState extends ConsumerState<PaymentContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PaymentResponse? _paymentResponse;
  bool _showProcessingDialog = false;

  @override
  void initState() {
    super.initState();
    // Load transactions on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerPaymentProvider.notifier).loadTransactions();
    });
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _showProcessingDialog = true;
    });

    final response =
        await ref.read(customerPaymentProvider.notifier).processPayment();

    setState(() {
      _paymentResponse = response;
    });

    // Auto-close dialog after 5 seconds for pending payments
    if (response.status == PaymentStatus.pending) {
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        setState(() {
          _showProcessingDialog = false;
        });
        _showSuccessMessage();
      }
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Payment initiated successfully! Check your phone.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _retryPayment() {
    if (_paymentResponse?.paymentId != null) {
      ref
          .read(customerPaymentProvider.notifier)
          .retryPayment(_paymentResponse!.paymentId!);
    }
    setState(() {
      _showProcessingDialog = false;
      _paymentResponse = null;
    });
  }

  void _closeDialog() {
    setState(() {
      _showProcessingDialog = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Check if user is authenticated
    if (!isAuthenticated) {
      return const Center(
        child: Text('Please login to make payments'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),

                    const SizedBox(height: 24),

                    // Payment Purpose Selector
                    const PaymentPurposeSelector(),

                    const SizedBox(height: 24),

                    // Payment Method Tabs
                    const PaymentMethodTabs(),

                    const SizedBox(height: 24),

                    // Payment Summary Card
                    PaymentSummaryCard(
                      onPayPressed: _processPayment,
                    ),

                    const SizedBox(height: 40),

                    // Security Information
                    _buildSecurityInfo(ref),
                  ],
                ),
              ),
            ),

            // Processing Dialog
            if (_showProcessingDialog)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: PaymentProcessingDialog(
                    response: _paymentResponse,
                    onClose: _closeDialog,
                    onRetry: _retryPayment,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            Text(
              'Make Payment',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Pay your water or sewerage bill securely',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityInfo(WidgetRef ref) {
    final securityInfo = ref.watch(securityInfoProvider);
    final deviceInfo =
        ref.watch(customerPaymentProvider.select((state) => state.deviceInfo));

    if (securityInfo == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.blueGrey[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Security Information',
                style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSecurityDetail('Device', deviceInfo?.deviceModel ?? 'Unknown'),
          const SizedBox(height: 8),
          _buildSecurityDetail('IP Address', securityInfo.ipAddress),
          const SizedBox(height: 8),
          _buildSecurityDetail('Risk Score', '${securityInfo.riskScore}/100'),
          if (securityInfo.isSuspicious)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.orange[700],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'This payment requires additional verification',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecurityDetail(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.blueGrey[600],
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.blueGrey[800],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
