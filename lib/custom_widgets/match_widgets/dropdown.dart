import 'package:flutter/material.dart';
import 'package:pressable_flutter/pressable_flutter.dart';

class Dropdown extends StatefulWidget {
  final String title;

  final List<String> items;
  final Function(String?)? onChanged;
  final double xValue;
  final double yValue;
  final Color backgroundColor;
  final int? initialIndex;

  const Dropdown({
    this.initialIndex,
    required this.title,
    required this.backgroundColor,

    required this.items,
    required this.xValue,
    required this.yValue,
    this.onChanged,
    super.key,
  });

  @override
  State<Dropdown> createState() => _DropdownState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _DropdownState extends State<Dropdown> {
  late String dropdownValue;
  late List<String> safeItems;

  @override
  void initState() {
    super.initState();
    safeItems = widget.items.isNotEmpty
        ? widget.items
        : (widget.title.isNotEmpty ? [widget.title] : ['Option']);
    dropdownValue = safeItems.first;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.xValue,
      height: widget.yValue,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final verticalPadding =
          ((constraints.maxHeight - 24) / 2).clamp(6.0, 18.0);
          final selectedValue = widget.initialIndex != null &&
              widget.initialIndex! >= 0 &&
              widget.initialIndex! < safeItems.length
              ? safeItems[widget.initialIndex!]
              : dropdownValue;
          return Pressable(
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: widget.title.isNotEmpty ? widget.title : null,
                hintStyle: const TextStyle(fontSize: 16, color: Colors.black),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.black, width: 1.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.black, width: 1.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.black, width: 1.0),
                ),
                isDense: false,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: verticalPadding,
                ),
              ),
              child: SizedBox.expand(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.title.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedValue,
                          isExpanded: true,
                          dropdownColor: widget.backgroundColor,
                          style: const TextStyle(color: Colors.black),
                          items: safeItems
                              .map(
                                (String value) =>
                                DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ),
                          )
                              .toList(),
                          onChanged: widget.onChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
