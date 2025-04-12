import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.label, this.fun});
  final String label;
  final VoidCallback? fun;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: fun,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[200], // Button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Rounded corners
          ),
        ),
        child: Text(label, style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
