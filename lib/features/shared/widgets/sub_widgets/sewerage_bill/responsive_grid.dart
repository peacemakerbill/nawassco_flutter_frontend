import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double spacing;
  final EdgeInsets padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 1.5,
    this.spacing = 16,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Determine columns based on screen width
        int crossAxisCount;
        if (width > 1200) {
          crossAxisCount = 4;
        } else if (width > 800) {
          crossAxisCount = 3;
        } else if (width > 600) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return Padding(
          padding: padding,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        );
      },
    );
  }
}