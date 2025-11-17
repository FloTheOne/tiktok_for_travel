import 'package:flutter/material.dart';

class LocationListTile extends StatelessWidget {
  const LocationListTile(
      {super.key, required this.location, required this.press});

  final String location;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.tightFor(
          height: 80), // Adjust the height as needed
      child: Column(
        children: [
          ListTile(
            onTap: press,
            horizontalTitleGap: 0,
            title: Text(
              location,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(
            height: 2,
            thickness: 2,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
