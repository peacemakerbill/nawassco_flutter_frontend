import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/customer_payment_provider.dart';

class AirtelPaymentForm extends ConsumerStatefulWidget {
  const AirtelPaymentForm({Key? key}) : super(key: key);

  @override
  _AirtelPaymentFormState createState() => _AirtelPaymentFormState();
}

class _AirtelPaymentFormState extends ConsumerState<AirtelPaymentForm> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final phoneNumber = ref.read(phoneNumberProvider);
      final amount = ref.read(amountProvider);
      _phoneController.text = phoneNumber;
      _amountController.text = amount > 0 ? amount.toStringAsFixed(2) : '';
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = ref.watch(phoneNumberProvider);
    final amount = ref.watch(amountProvider);
    final notifier = ref.read(customerPaymentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Airtel Money Info
        _buildInfoCard(),

        const SizedBox(height: 24),

        // Phone Number Input
        Text(
          'Airtel Money Number',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'e.g., 07XXXXXXXX',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            notifier.setPhoneNumber(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your Airtel Money number';
            }
            if (!RegExp(r'^(?:254|\+254|0)?(7\d{8})$').hasMatch(value.replaceAll(' ', ''))) {
              return 'Please enter a valid Kenyan phone number';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Amount Input
        Text(
          'Amount (KES)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'e.g., 1500.00',
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0;
            notifier.setAmount(amount);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            if (amount > 150000) {
              return 'Maximum amount is KES 150,000';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Transaction Fee
        _buildFeeInfo(amount),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.red[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Airtel Money Payment',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You will receive a USSD prompt on your phone. Please follow the instructions to complete the payment.',
                  style: TextStyle(
                    color: Colors.red[700],
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

  Widget _buildFeeInfo(double amount) {
    const fee = 15.0;
    final total = amount + fee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount:',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                'KES ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction Fee:',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                'KES ${fee.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'KES ${total.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}