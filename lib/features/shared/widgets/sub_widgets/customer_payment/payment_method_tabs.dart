import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/customer_payment_provider.dart';
import '../../../models/customer_payment_model.dart';
import 'airtel_payment_form.dart';
import 'mpesa_payment_form.dart';


class PaymentMethodTabs extends ConsumerWidget {
  const PaymentMethodTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(selectedPaymentMethodProvider);
    final notifier = ref.read(customerPaymentProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab Headers
          Row(
            children: [
              _buildTab(
                context,
                ref,
                label: 'M-Pesa',
                method: PaymentMethod.mpesa,
                icon: Icons.phone_android,
                isActive: selectedMethod == PaymentMethod.mpesa,
              ),
              _buildTab(
                context,
                ref,
                label: 'Airtel Money',
                method: PaymentMethod.airtelMoney,
                icon: Icons.currency_exchange,
                isActive: selectedMethod == PaymentMethod.airtelMoney,
              ),
            ],
          ),

          // Tab Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: selectedMethod == PaymentMethod.mpesa
                  ? const MpesaPaymentForm()
                  : const AirtelPaymentForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
      BuildContext context,
      WidgetRef ref,
      {
        required String label,
        required PaymentMethod method,
        required IconData icon,
        required bool isActive,
      }
      ) {
    final notifier = ref.read(customerPaymentProvider.notifier);

    return Expanded(
      child: InkWell(
        onTap: () => notifier.setPaymentMethod(method),
        borderRadius: BorderRadius.only(
          topLeft: method == PaymentMethod.mpesa ? const Radius.circular(12) : Radius.zero,
          topRight: method == PaymentMethod.airtelMoney ? const Radius.circular(12) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).primaryColor : Colors.grey[50],
            borderRadius: BorderRadius.only(
              topLeft: method == PaymentMethod.mpesa ? const Radius.circular(12) : Radius.zero,
              topRight: method == PaymentMethod.airtelMoney ? const Radius.circular(12) : Radius.zero,
            ),
            border: isActive
                ? null
                : Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}