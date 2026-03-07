import 'package:flutter/material.dart';

class ChartsRow extends StatelessWidget {
  const ChartsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 768) {
      // Mobile layout - stacked
      return Column(
        children: [
          _buildWaterProductionChart(),
          const SizedBox(height: 16),
          _buildRevenueChart(),
        ],
      );
    } else {
      // Desktop layout - side by side
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildWaterProductionChart(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildRevenueChart(),
          ),
        ],
      );
    }
  }

  Widget _buildWaterProductionChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop, color: Color(0xFF0066CC), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Water Production vs Demand',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.fullscreen, color: Colors.grey.shade600, size: 18),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(Size(36, 36)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Water Production Chart
            Container(
              height: 180,
              padding: const EdgeInsets.all(8),
              child: CustomPaint(
                size: Size.infinite,
                painter: _WaterProductionChartPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Color(0xFF00B894), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Revenue Collection Trend',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.fullscreen, color: Colors.grey.shade600, size: 18),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tight(Size(36, 36)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Revenue Chart
            Container(
              height: 180,
              padding: const EdgeInsets.all(8),
              child: CustomPaint(
                size: Size.infinite,
                painter: _RevenueChartPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom chart painters for the dashboard
class _WaterProductionChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF0066CC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = Color(0xFF0066CC).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width, size.height * 0.3),
    ];

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Create fill path
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = Color(0xFF0066CC)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 2, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RevenueChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF00B894)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = Color(0xFF00B894).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width, size.height * 0.1),
    ];

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Create fill path
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = Color(0xFF00B894)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 2, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}