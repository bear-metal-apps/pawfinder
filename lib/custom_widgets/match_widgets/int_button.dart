import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

// IMPORTANT: Font size automatically scales with screen size, but the text alignment and button size are fixed.
// Number button widget that adds and substracts a numerical value.
class NumberButton extends StatefulWidget {
  final Color? backgroundColor;
  final Alignment textAlignment;
  final String dataName;
  final Function(int)? onChanged;
  final double xLength;
  final double yLength;
  final bool? negativeAllowed;
  final int? initialValue;

  const NumberButton({
    super.key,
    this.initialValue,
    this.negativeAllowed,
    this.onChanged,
    this.backgroundColor,
    required this.dataName,
    required this.xLength,
    required this.yLength,
    this.textAlignment = Alignment.bottomRight,
  });

  @override
  State<NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<NumberButton> {
  late int currentVariable = widget.initialValue ?? 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final buttonHeight = (height * 0.3).clamp(28.0, 44.0);
          final allowNegative = widget.negativeAllowed ?? false;

          return Pressable(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentVariable++;
                });

                widget.onChanged?.call(currentVariable);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.backgroundColor ?? Colors.white,
                side: const BorderSide(color: Colors.black, width: 1),
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${widget.dataName}: $currentVariable',
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
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: buttonHeight * 1.6,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (allowNegative) {
                              currentVariable--;
                            } else if (currentVariable > 0) {
                              currentVariable--;
                            }
                          });

                          widget.onChanged?.call(currentVariable);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black, width: 1),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Icon(Icons.remove),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
