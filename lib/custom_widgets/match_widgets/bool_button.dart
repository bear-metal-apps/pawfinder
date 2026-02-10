import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

class BoolButton extends StatefulWidget {
  final String dataName;
  final double xLength;
  final double yLength;
  final Function(bool) onChanged;
  final double? minfontSize; // Optional font size parameter
  final bool visualFeedback;
  final bool? initialValue;

  const BoolButton({
    super.key,
    this.initialValue,
    this.minfontSize,
    required this.dataName,
    required this.xLength,
    required this.yLength,
    required this.onChanged,
    required this.visualFeedback,
  });

  @override
  _BoolButtonState createState() => _BoolButtonState();
}

class _BoolButtonState extends State<BoolButton> {
  late bool boolButtonState = widget.initialValue ?? false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding =
          (constraints.biggest.shortestSide * 0.12).clamp(6.0, 16.0);

          return Pressable(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
                side: const BorderSide(color: Colors.black, width: 1),
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                foregroundColor: Colors.black,
                backgroundColor: (boolButtonState == false)
                    ? Colors.red
                    : Colors.green,
                padding: EdgeInsets.all(padding),
                minimumSize: Size(widget.xLength, widget.yLength),
              ),
              onPressed: () {
                setState(() {
                  boolButtonState = !boolButtonState;
                });
                widget.onChanged(boolButtonState);
              },
              child: Center(
                child: AutoSizeText(
                  widget.dataName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: widget.minfontSize ?? 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
