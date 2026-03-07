import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';

class CustomerSignaturePad extends StatefulWidget {
  final Function(Uint8List?) onSignatureSaved;
  final String? existingSignatureUrl;

  const CustomerSignaturePad({
    super.key,
    required this.onSignatureSaved,
    this.existingSignatureUrl,
  });

  @override
  State<CustomerSignaturePad> createState() => _CustomerSignaturePadState();
}

class _CustomerSignaturePadState extends State<CustomerSignaturePad> {
  List<Offset> _points = [];
  final GlobalKey _signatureKey = GlobalKey();
  bool _isLoading = false;
  ui.Image? _existingSignatureImage;

  @override
  void initState() {
    super.initState();
    _loadExistingSignature();
  }

  Future<void> _loadExistingSignature() async {
    if (widget.existingSignatureUrl != null) {
      try {
        // Handle both base64 data URLs and regular URLs
        if (widget.existingSignatureUrl!.startsWith('data:')) {
          // Extract base64 from data URL
          final base64Data = widget.existingSignatureUrl!.split(',').last;
          final bytes = base64.decode(base64Data);
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          setState(() {
            _existingSignatureImage = frame.image;
          });
        }
      } catch (error) {
        print('Error loading existing signature: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Signature'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSignature,
            tooltip: 'Save Signature',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearSignature,
            tooltip: 'Clear Signature',
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: const Column(
              children: [
                Text(
                  'Please sign below',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Customer signature confirms work completion and satisfaction',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Signature Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: RepaintBoundary(
                key: _signatureKey,
                child: Stack(
                  children: [
                    // Existing signature (if any)
                    if (_existingSignatureImage != null)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ExistingSignaturePainter(_existingSignatureImage!),
                        ),
                      ),

                    // Current drawing surface
                    GestureDetector(
                      onPanStart: (DragStartDetails details) {
                        setState(() {
                          RenderBox renderBox = context.findRenderObject() as RenderBox;
                          _points.add(renderBox.globalToLocal(details.globalPosition));
                        });
                      },
                      onPanUpdate: (DragUpdateDetails details) {
                        setState(() {
                          RenderBox renderBox = context.findRenderObject() as RenderBox;
                          _points.add(renderBox.globalToLocal(details.globalPosition));
                        });
                      },
                      onPanEnd: (DragEndDetails details) {
                        setState(() {
                          _points.add(Offset.zero);
                        });
                      },
                      child: CustomPaint(
                        painter: SignaturePainter(_points),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearSignature,
                    child: const Text('CLEAR'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_points.isNotEmpty || _existingSignatureImage != null)
                        ? _saveSignature
                        : null,
                    child: _isLoading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('SAVE SIGNATURE'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _clearSignature() {
    setState(() {
      _points.clear();
      _existingSignatureImage = null;
    });
  }

  Future<void> _saveSignature() async {
    if (_points.isEmpty && _existingSignatureImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a signature')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final imageData = await _captureSignature();
      widget.onSignatureSaved(imageData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signature saved successfully')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save signature: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Uint8List?> _captureSignature() async {
    try {
      final RenderRepaintBoundary boundary =
      _signatureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        // Compress the image
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // Resize to reasonable dimensions
        final img.Image? decodedImage = img.decodeImage(pngBytes);
        if (decodedImage != null) {
          final img.Image resizedImage = img.copyResize(decodedImage, width: 800, height: 400);
          final Uint8List resizedBytes = img.encodePng(resizedImage);

          // Optional: Further compress
          final img.Image compressedImage = img.copyResize(resizedImage, width: 600, height: 300);
          final Uint8List finalBytes = img.encodePng(compressedImage);
          return finalBytes;
        }

        return pngBytes;
      }
      return null;
    } catch (error) {
      print('Error capturing signature: $error');
      return null;
    }
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => oldDelegate.points != points;
}

class ExistingSignaturePainter extends CustomPainter {
  final ui.Image image;

  ExistingSignaturePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(ExistingSignaturePainter oldDelegate) => oldDelegate.image != image;
}