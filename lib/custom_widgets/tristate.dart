import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';
import 'package:beariscope_scouter/custom_widgets/undo_redo.dart';

class TristateButton extends StatefulWidget {
  final String dataName;
  final double xLength;
  final double yLength;
  final Function(int) onChanged;
  final double? minfontSize; // Optional font size parameter
  final int? initialState;
  const TristateButton({
    super.key,
    this.initialState,
    this.minfontSize,
    required this.dataName,
    required this.xLength,
    required this.yLength,
    required this.onChanged,
  });

  @override
  _TristateState createState() => _TristateState();
}

class _TristateState extends State<TristateButton> {
  late int currentState =
      widget.initialState ?? 0; // 0: unchecked, 1: checked, 2: indeterminate
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xLength,
      height: widget.yLength,
      child: Pressable(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            foregroundColor: Colors.black,
            backgroundColor: (currentState == 0
                ? Colors.red
                : currentState == 1
                ? Colors.green
                : currentState == 2
                ? Colors.yellow
                : Colors.grey),
          ),
          onPressed: () {
            final oldValue = currentState;
            final newValue = (oldValue == 0) ? 1 : (oldValue == 1) ? 2 : 0;

            void apply(int v) {
              setState(() {
                currentState = v;
              });
              widget.onChanged(v);
            }

            final cmd = PropertyChangeCommand<int>(
              setter: apply,
              newValue: newValue,
              oldValue: oldValue,
            );
            UndoRedoManager().execute(cmd);
          },
          child: Center(
            child: AutoSizeText(
              widget.dataName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize:
                    widget.minfontSize ??
                    20.0, // Use the provided font size or default to 16.0
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
