import 'package:flutter/material.dart';

class CustomSelectBox extends StatefulWidget {
  final String selectedVal;
  final String label;
  final double? width;
  final List<dynamic> items;
  final void Function(dynamic value)? onChanged;
  final String? Function(Object? value)? validator;

  const CustomSelectBox(
      {Key? key,
      this.width,
      required this.items,
      required this.selectedVal,
      required this.label,
      required this.onChanged,
      this.validator})
      : super(key: key);

  @override
  State<CustomSelectBox> createState() => _CustomSelectBoxState();
}

class _CustomSelectBoxState extends State<CustomSelectBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          label: Text(widget.label),
        ),
        validator: widget.validator,
        value: widget.selectedVal.isNotEmpty ? widget.selectedVal : null,
        items: widget.items.map((e) {
          return DropdownMenuItem(
              value: e['id'].toString(), child: Text(e['Name']));
        }).toList(),
        onChanged: widget.onChanged,
        icon: const Icon(
          Icons.arrow_drop_down_circle,
          color: Colors.green,
        ),
      ),
    );
  }
}
