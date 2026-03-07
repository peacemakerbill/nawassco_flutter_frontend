import 'package:flutter/material.dart';

import '../../../../models/field_customer.dart';

class CustomerCard extends StatelessWidget {
  final FieldCustomer customer;
  final VoidCallback onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar/Initials
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    customer.firstName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          customer.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                customer.accountStatus.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: customer.accountStatus.color
                                    .withOpacity(0.3)),
                          ),
                          child: Text(
                            customer.accountStatus.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: customer.accountStatus.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cust #${customer.customerNumber} | ${customer.accountNumber}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${customer.phoneNumber} • ${customer.email}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.address.fullAddress,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Balance and Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    customer.formattedBalance,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: customer.hasOutstandingBalance
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer.customerType.displayName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.phone, size: 18),
                        onPressed: () => _callCustomer(customer.phoneNumber),
                        tooltip: 'Call',
                      ),
                      IconButton(
                        icon: const Icon(Icons.email, size: 18),
                        onPressed: () => _emailCustomer(customer.email),
                        tooltip: 'Email',
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 18),
                        onPressed: () => _showMoreOptions(context, customer),
                        tooltip: 'More',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _callCustomer(String phoneNumber) {
    // Implement call functionality
  }

  void _emailCustomer(String email) {
    // Implement email functionality
  }

  void _showMoreOptions(BuildContext context, FieldCustomer customer) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Customer'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('View Billing'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to billing
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Service History'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to service history
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Create Work Order'),
              onTap: () {
                Navigator.pop(context);
                // Create work order
              },
            ),
            if (customer.hasOutstandingBalance)
              ListTile(
                leading: const Icon(Icons.payment, color: Colors.green),
                title: const Text('Record Payment'),
                onTap: () {
                  Navigator.pop(context);
                  // Record payment
                },
              ),
          ],
        );
      },
    );
  }
}
