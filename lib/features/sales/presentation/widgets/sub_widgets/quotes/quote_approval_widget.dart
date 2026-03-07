import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/quote.model.dart';
import '../../../../providers/quote_provider.dart';

class QuoteApprovalWidget extends ConsumerStatefulWidget {
  final Quote quote;

  const QuoteApprovalWidget({super.key, required this.quote});

  @override
  ConsumerState<QuoteApprovalWidget> createState() =>
      _QuoteApprovalWidgetState();
}

class _QuoteApprovalWidgetState extends ConsumerState<QuoteApprovalWidget> {
  final TextEditingController _commentsController = TextEditingController();
  bool _isApproving = true;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isApproving) {
      ref.read(quoteProvider.notifier).approveQuote(
        widget.quote.id,
        comments: _commentsController.text.isNotEmpty
            ? _commentsController.text
            : null,
      );
    } else {
      ref.read(quoteProvider.notifier).rejectQuote(
        widget.quote.id,
        comments: _commentsController.text.isNotEmpty
            ? _commentsController.text
            : null,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final quoteState = ref.watch(quoteProvider);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isApproving ? 'Approve Quote' : 'Reject Quote',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.quote.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              // Toggle Buttons
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isApproving = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isApproving
                              ? Colors.green
                              : Colors.transparent,
                          foregroundColor:
                          _isApproving ? Colors.white : Colors.grey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.thumb_up, size: 20),
                            SizedBox(width: 8),
                            Text('Approve'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isApproving = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_isApproving
                              ? Colors.red
                              : Colors.transparent,
                          foregroundColor:
                          !_isApproving ? Colors.white : Colors.grey,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.thumb_down, size: 20),
                            SizedBox(width: 8),
                            Text('Reject'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Comments
              TextFormField(
                controller: _commentsController,
                decoration: InputDecoration(
                  labelText: 'Comments (Optional)',
                  hintText: 'Enter your comments here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isApproving
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isApproving
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isApproving ? Icons.check_circle : Icons.warning,
                      color: _isApproving ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isApproving
                            ? 'This will approve the quote and notify the customer.'
                            : 'This will reject the quote and notify the customer.',
                        style: TextStyle(
                          color: _isApproving ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF1E3A8A)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: quoteState.isApproving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isApproving ? Colors.green : Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: quoteState.isApproving
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : Text(_isApproving ? 'Approve' : 'Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}