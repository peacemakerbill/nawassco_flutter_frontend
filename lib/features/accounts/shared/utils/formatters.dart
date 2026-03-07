import 'package:intl/intl.dart';

class Formatters {
  // Currency formatter for Kenyan Shillings
  static final NumberFormat currency = NumberFormat.currency(
    locale: 'en_KE',
    symbol: 'KES ',
    decimalDigits: 2,
  );

  // Date formatters
  static final DateFormat dateOnly = DateFormat('dd/MM/yyyy');
  static final DateFormat dateTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat monthYear = DateFormat('MMM yyyy');
  static final DateFormat fullDate = DateFormat('EEEE, MMMM d, yyyy');

  // Number formatters
  static final NumberFormat compactCurrency = NumberFormat.compactCurrency(
    locale: 'en_KE',
    symbol: 'KES ',
  );

  static final NumberFormat decimal = NumberFormat.decimalPattern('en_KE');
  static final NumberFormat percent = NumberFormat.percentPattern();

  // Format currency amount
  static String formatCurrency(double amount) {
    return currency.format(amount);
  }

  // Format large currency amounts in compact form
  static String formatCompactCurrency(double amount) {
    return compactCurrency.format(amount);
  }

  // Format date
  static String formatDate(DateTime date) {
    return dateOnly.format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return dateTime.format(date);
  }

  // Format month and year
  static String formatMonthYear(DateTime date) {
    return monthYear.format(date);
  }

  // Format full date
  static String formatFullDate(DateTime date) {
    return fullDate.format(date);
  }

  // Format decimal number
  static String formatDecimal(num number) {
    return decimal.format(number);
  }

  // Format percentage
  static String formatPercent(double value) {
    return percent.format(value);
  }

  // Format phone number (Kenyan format)
  static String formatPhoneNumber(String phone) {
    if (phone.startsWith('+254')) {
      return phone.replaceFirst('+254', '0');
    } else if (phone.startsWith('254')) {
      return '0${phone.substring(3)}';
    }
    return phone;
  }

  // Format account number with spacing
  static String formatAccountNumber(String accountNumber) {
    if (accountNumber.length <= 8) return accountNumber;
    return '${accountNumber.substring(0, 3)}-${accountNumber.substring(3, 6)}-${accountNumber.substring(6)}';
  }

  // Format service number
  static String formatMeterNumber(String meterNumber) {
    if (meterNumber.length <= 8) return meterNumber;
    return 'MTR-${meterNumber.substring(0, 3)}-${meterNumber.substring(3)}';
  }

  // Format large numbers with K, M suffixes
  static String formatCompactNumber(num number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  // Format duration
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) return '${duration.inDays} days';
    if (duration.inHours > 0) return '${duration.inHours} hours';
    if (duration.inMinutes > 0) return '${duration.inMinutes} minutes';
    return '${duration.inSeconds} seconds';
  }

  // Format time ago
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Format status with color coding
  static Map<String, dynamic> formatStatus(String status) {
    final lowerStatus = status.toLowerCase();

    return switch (lowerStatus) {
      'active' => {'color': 0xFF22C55E, 'text': 'Active'},
      'inactive' => {'color': 0xFF6B7280, 'text': 'Inactive'},
      'overdue' => {'color': 0xFFF59E0B, 'text': 'Overdue'},
      'delinquent' => {'color': 0xFFEF4444, 'text': 'Delinquent'},
      'paid' => {'color': 0xFF22C55E, 'text': 'Paid'},
      'pending' => {'color': 0xFFF59E0B, 'text': 'Pending'},
      'completed' => {'color': 0xFF22C55E, 'text': 'Completed'},
      'cancelled' => {'color': 0xFFEF4444, 'text': 'Cancelled'},
      'scheduled' => {'color': 0xFF3B82F6, 'text': 'Scheduled'},
      'in progress' => {'color': 0xFF8B5CF6, 'text': 'In Progress'},
      _ => {'color': 0xFF6B7280, 'text': status},
    };
  }

  // Format customer type
  static String formatCustomerType(String type) {
    return switch (type.toLowerCase()) {
      'residential' => 'Residential',
      'commercial' => 'Commercial',
      'industrial' => 'Industrial',
      'government' => 'Government',
      _ => type,
    };
  }

  // Format payment method
  static String formatPaymentMethod(String method) {
    return switch (method.toLowerCase()) {
      'mpesa' => 'M-Pesa',
      'cash' => 'Cash',
      'bank' => 'Bank Transfer',
      'cheque' => 'Cheque',
      'card' => 'Credit/Debit Card',
      _ => method,
    };
  }

  // Mask sensitive information
  static String maskSensitiveInfo(String info, {int visibleChars = 4}) {
    if (info.length <= visibleChars * 2) return info;
    final start = info.substring(0, visibleChars);
    final end = info.substring(info.length - visibleChars);
    final masked = '*' * (info.length - visibleChars * 2);
    return '$start$masked$end';
  }
}