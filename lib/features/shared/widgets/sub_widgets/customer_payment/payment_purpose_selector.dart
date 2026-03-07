import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/customer_payment_provider.dart';
import '../../../models/customer_payment_model.dart';

class PaymentPurposeSelector extends ConsumerWidget {
  const PaymentPurposeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPurpose = ref.watch(selectedPaymentPurposeProvider);
    final notifier = ref.read(customerPaymentProvider.notifier);
    final accountNumber = ref.watch(accountNumberProvider);

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Purpose',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Purpose Options
            Row(
              children: [
                _buildPurposeOption(
                  context,
                  ref,
                  title: 'Water Bill',
                  description: 'Pay your water utility bill',
                  icon: Icons.water_drop,
                  purpose: PaymentPurpose.waterBill,
                  isSelected: selectedPurpose == PaymentPurpose.waterBill,
                ),
                const SizedBox(width: 16),
                _buildPurposeOption(
                  context,
                  ref,
                  title: 'Sewerage Bill',
                  description: 'Pay your sewerage service bill',
                  icon: Icons.dirty_lens,
                  purpose: PaymentPurpose.sewerageBill,
                  isSelected: selectedPurpose == PaymentPurpose.sewerageBill,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Account Number Input
            Text(
              selectedPurpose == PaymentPurpose.waterBill
                  ? 'Water Meter Number'
                  : 'Sewerage Service Number',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: accountNumber,
              decoration: InputDecoration(
                hintText: selectedPurpose == PaymentPurpose.waterBill
                    ? 'Enter your water service number'
                    : 'Enter your sewerage service number',
                prefixIcon: const Icon(Icons.numbers),
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
                notifier.setAccountNumber(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your account number';
                }

                if (selectedPurpose == PaymentPurpose.waterBill) {
                  if (!value.contains(RegExp(r'^[A-Z0-9]+$'))) {
                    return 'Please enter a valid water service number';
                  }
                } else {
                  if (!value.contains(RegExp(r'^SEW-\d{8}-[A-Z0-9]+$'))) {
                    return 'Please enter a valid sewerage service number (format: SEW-YYYYMMDD-XXXXXX)';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Help Text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedPurpose == PaymentPurpose.waterBill
                          ? 'Your water service number is printed on your bill. It usually contains letters and numbers.'
                          : 'Your sewerage service number starts with SEW- followed by date and a unique code.',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 12,
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

  Widget _buildPurposeOption(
      BuildContext context,
      WidgetRef ref,
      {
        required String title,
        required String description,
        required IconData icon,
        required PaymentPurpose purpose,
        required bool isSelected,
      }
      ) {
    final notifier = ref.read(customerPaymentProvider.notifier);

    return Expanded(
      child: InkWell(
        onTap: () => notifier.setPaymentPurpose(purpose),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.8)
                      : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}