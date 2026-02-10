import 'package:flutter/material.dart';

class BigNumberWidget extends StatefulWidget {
  final double xLength;
  final double yLength;
  final List<int> buttons;
  final Color? backgroundColor;
  final String text;
  final int? initialValue;
  final Function(int)? onChanged;

  const BigNumberWidget({
    super.key,
    this.backgroundColor,
    required this.buttons,
    required this.xLength,
    required this.yLength,
    required this.text,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<BigNumberWidget> createState() => _BigNumberWidget();
}

class _BigNumberWidget extends State<BigNumberWidget> {
  late int currentValue = widget.initialValue ?? 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final headerHeight = height * 0.28;
          final gridHeight = (height - headerHeight).clamp(0.0, height);
          final rows = (widget.buttons.length / 3).ceil().clamp(1, 6);
          final cellHeight = gridHeight / rows;
          final cellWidth = width / 3;
          final aspectRatio = cellHeight > 0 ? cellWidth / cellHeight : 1.0;

          return Column(
            children: [
              SizedBox(
                height: headerHeight,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "${widget.text}: $currentValue",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: gridHeight,
                width: width,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: widget.buttons.length,
                  itemBuilder: (context, index) {
                    final value = widget.buttons[index];
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentValue += value;
                          });
                          widget.onChanged?.call(currentValue);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          widget.backgroundColor ?? Colors.white,
                          side: const BorderSide(color: Colors.black, width: 1),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            value > 0 ? "+$value" : value.toString(),
                          ),
                        ),
                      ),
                    );
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
