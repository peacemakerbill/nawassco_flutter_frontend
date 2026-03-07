import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../models/customer_payment_model.dart';

class PaymentProcessingDialog extends StatefulWidget {
  final PaymentResponse? response;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  const PaymentProcessingDialog({
    Key? key,
    this.response,
    required this.onClose,
    required this.onRetry,
  }) : super(key: key);

  @override
  _PaymentProcessingDialogState createState() => _PaymentProcessingDialogState();
}

class _PaymentProcessingDialogState extends State<PaymentProcessingDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  PaymentStatus? _currentStatus;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _controller.repeat();

    _currentStatus = widget.response?.status ?? PaymentStatus.pending;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (_currentStatus) {
      case PaymentStatus.completed:
        return _buildSuccessDialog();
      case PaymentStatus.failed:
        return _buildFailedDialog();
      case PaymentStatus.pending:
      default:
        return _buildProcessingDialog();
    }
  }

  Widget _buildProcessingDialog() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lottie animation
          SizedBox(
            width: 150,
            height: 150,
            child: Lottie.asset(
              'assets/animations/payment_processing.json',
              controller: _controller,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'Processing Payment',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            'Please wait while we process your payment.\nThis may take a few seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 32),

          // Progress indicator
          LinearProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),

          const SizedBox(height: 24),

          // Payment Details
          if (widget.response != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Reference', widget.response!.checkoutRequestID ?? widget.response!.transactionId ?? '---'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Amount', 'KES ${widget.response!.amount?.toStringAsFixed(2) ?? "---"}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessDialog() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'Payment Successful!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.green[800],
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            'Your payment has been processed successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 32),

          // Payment Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Column(
              children: [
                _buildDetailRow('Transaction ID', widget.response!.paymentId ?? '---'),
                const SizedBox(height: 8),
                if (widget.response!.checkoutRequestID != null)
                  _buildDetailRow('Checkout ID', widget.response!.checkoutRequestID!),
                if (widget.response!.transactionId != null)
                  _buildDetailRow('Transaction ID', widget.response!.transactionId!),
                const SizedBox(height: 8),
                _buildDetailRow('Amount', 'KES ${widget.response!.amount?.toStringAsFixed(2) ?? "---"}'),
                const SizedBox(height: 8),
                _buildDetailRow('Account', widget.response!.accountNumber ?? '---'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implement receipt download
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Download Receipt'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFailedDialog() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red[600],
              size: 60,
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'Payment Failed',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.red[800],
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            widget.response?.message ?? 'Payment could not be processed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 32),

          // Error Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[100]!),
            ),
            child: Column(
              children: [
                _buildDetailRow('Error', widget.response?.message ?? 'Unknown error'),
                const SizedBox(height: 8),
                if (widget.response!.paymentId != null)
                  _buildDetailRow('Payment ID', widget.response!.paymentId!),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClose,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}