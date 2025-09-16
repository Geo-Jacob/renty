import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final dynamic icon;
  final String text;

  const SocialAuthButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon is IconData 
          ? Icon(icon as IconData, size: 24)
          : Image.asset(
              icon as String,
              width: 20,
              height: 20,
            ),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}