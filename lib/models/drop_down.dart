import 'package:flutter/material.dart';
import 'package:tiktok_travel/constants.dart';

class DropdownMenuExample extends StatefulWidget {
  const DropdownMenuExample({super.key});

  // Define a static method to get the selected category
  static String selectedCategory = dropDownList.first;

  // Update the selected category when a new value is selected
  static void setSelectedCategory(String value) {
    selectedCategory = value;
  }

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
  String dropdownValue = dropDownList.first;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: dropDownList.first,
      onSelected: (String? value) {
        // Update the selected category when a new value is selected
        DropdownMenuExample.setSelectedCategory(value!);
        setState(() {
          dropdownValue = value;
        });
      },
      dropdownMenuEntries:
          dropDownList.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );
  }
}
