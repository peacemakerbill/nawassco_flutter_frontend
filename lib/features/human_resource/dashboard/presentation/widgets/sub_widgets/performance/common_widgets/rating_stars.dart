import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool showNumber;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5.0,
    this.size = 24.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.showNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showNumber)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: size * 0.8,
                fontWeight: FontWeight.bold,
                color: activeColor,
              ),
            ),
          ),
        ...List.generate(maxRating.toInt(), (index) {
          final starIndex = index + 1;
          IconData icon;
          Color color;

          if (rating >= starIndex) {
            icon = Icons.star;
            color = activeColor;
          } else if (rating > starIndex - 1) {
            icon = Icons.star_half;
            color = activeColor;
          } else {
            icon = Icons.star_border;
            color = inactiveColor;
          }

          return Icon(
            icon,
            size: size,
            color: color,
          );
        }),
      ],
    );
  }
}

class EditableRatingStars extends StatefulWidget {
  final double initialRating;
  final double maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<double> onRatingChanged;
  final bool showLabel;

  const EditableRatingStars({
    super.key,
    required this.initialRating,
    this.maxRating = 5.0,
    this.size = 32.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    required this.onRatingChanged,
    this.showLabel = false,
  });

  @override
  State<EditableRatingStars> createState() => _EditableRatingStarsState();
}

class _EditableRatingStarsState extends State<EditableRatingStars> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Rating: ${_currentRating.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: widget.size * 0.5,
                color: Colors.grey,
              ),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.maxRating.toInt(), (index) {
            final starValue = index + 1.0;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentRating = starValue;
                });
                widget.onRatingChanged(_currentRating);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Icon(
                  _currentRating >= starValue ? Icons.star : Icons.star_border,
                  size: widget.size,
                  color: _currentRating >= starValue ? widget.activeColor : widget.inactiveColor,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}