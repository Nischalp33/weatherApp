import 'package:flutter/material.dart';

class DetailCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final String data;

  const DetailCard({
    super.key,
    required this.text,
    required this.data,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 1;
    return Expanded(
      child: SizedBox(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
          child: Padding(
            padding: EdgeInsets.all(width * .04),
            child: Column(
              children: [
                Icon(size: 32, icon),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  text,
                  style: const TextStyle(fontSize: 16, color: Colors.white60),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  data,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
