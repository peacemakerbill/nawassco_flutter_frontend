import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/customer_payment_model.dart';
import '../../../providers/customer_payment_provider.dart';


class PaymentSummaryCard extends ConsumerWidget {
  final VoidCallback onPayPressed;

  const PaymentSummaryCard({
    Key? key,
    required this.onPayPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(selectedPaymentMethodProvider);
    final selectedPurpose = ref.watch(selectedPaymentPurposeProvider);
    final accountNumber = ref.watch(accountNumberProvider);
    final phoneNumber = ref.watch(phoneNumberProvider);
    final amount = ref.watch(amountProvider);
    final isProcessing = ref.watch(isProcessingProvider);
    final canMakePayment = ref.watch(canMakePaymentProvider);
    final totalAmount = ref.watch(totalAmountProvider);

    final paymentMethod = selectedMethod == PaymentMethod.mpesa
        ? 'M-Pesa'
        : 'Airtel Money';

    final paymentPurpose = selectedPurpose == PaymentPurpose.waterBill
        ? 'Water Bill'
        : 'Sewerage Bill';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Payment Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // Summary Details
            _buildSummaryRow(
              context,
              label: 'Payment Method',
              value: paymentMethod,
              icon: Icons.payment,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              label: 'Payment Purpose',
              value: paymentPurpose,
              icon: Icons.receipt,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              label: 'Account Number',
              value: accountNumber.isNotEmpty ? accountNumber : 'Not entered',
              icon: Icons.numbers,
              valueColor: accountNumber.isNotEmpty ? null : Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              label: 'Phone Number',
              value: phoneNumber,
              icon: Icons.phone,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Amount Breakdown
            _buildAmountRow(
              context,
              label: 'Amount',
              amount: amount,
            ),
            const SizedBox(height: 8),
            _buildAmountRow(
              context,
              label: 'Transaction Fee',
              amount: totalAmount - amount,
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            _buildAmountRow(
              context,
              label: 'Total',
              amount: totalAmount,
              isTotal: true,
            ),

            const SizedBox(height: 30),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: canMakePayment && !isProcessing ? onPayPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isProcessing
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'PAY KES ${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Security Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.green[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your payment is secure and encrypted',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
      BuildContext context,
      {
        required String label,
        required String value,
        required IconData icon,
        Color? valueColor,
      }
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey[500],
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.grey[800],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(
      BuildContext context,
      {
        required String label,
        required double amount,
        bool isTotal = false,
      }
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.grey[800] : Colors.grey[600],
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          'KES ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isTotal ? Theme.of(context).primaryColor : Colors.grey[800],
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}