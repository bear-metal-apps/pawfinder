import 'package:flutter/material.dart';

class CustomSlider extends StatefulWidget {
  final String title;
  final double xValue;
  final double yValue;
  final int? segmentLength;
  final int minValue;
  final int maxValue;
  final double? initialValue;
  final Function(double) onChanged;

  const CustomSlider({
    required this.onChanged,
    required this.title,
    required this.xValue,
    required this.yValue,
    this.segmentLength,
    required this.minValue,
    required this.maxValue,
    this.initialValue,
    super.key,
  });
  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late double sliderValue = widget.initialValue ?? 0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xValue,
      height: widget.yValue,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final max = widget.maxValue.toDouble();
          final min = widget.minValue.toDouble();
          final divisions =
              widget.segmentLength != null && widget.segmentLength! > 0
              ? ((max - min) / widget.segmentLength!).round()
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: constraints.maxHeight * 0.35,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Slider(
                  min: min,
                  max: max,
                  divisions: divisions,
                  value: sliderValue.clamp(min, max),
                  onChanged: (value) {
                    widget.onChanged(value);
                    setState(() => sliderValue = value);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
