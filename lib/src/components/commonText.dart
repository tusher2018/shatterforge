import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget commonText(String text,
    {Color color = Colors.white,
    bool isBold = false,
    double size = 14,
    overflow = TextOverflow.ellipsis}) {
  return Text(
    text,
    overflow: overflow,
    style: GoogleFonts.gemunuLibre(
        color: color,
        fontSize: size,
        fontWeight: (isBold) ? FontWeight.w800 : FontWeight.normal),
  );
}

Widget commonButton(BuildContext context, String text, VoidCallback onPressed,
    {double fontSize = 22}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.sizeOf(context).width * 0.4,
      height: 40,
      decoration: BoxDecoration(
        // Simulating a golden gradient
        color: Color(0xFFEFEF5CE),

        borderRadius: BorderRadius.circular(15), // Rounded corners
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurStyle: BlurStyle.normal,
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.black,
            blurStyle: BlurStyle.inner,
            blurRadius: 6,
          ),
        ],
        border: Border.all(
          color: Colors.black,
          width: 2.5,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

void showCommonSnackbar(
  BuildContext context, {
  required String message,
  Color backgroundColor = Colors.black26,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
  bool isDismissible = true,
}) {
  final snackBar = SnackBar(
    content: Row(
      children: [
        if (icon != null)
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    duration: duration,
    action: isDismissible
        ? SnackBarAction(
            label: 'DISMISS',
            textColor: Colors.yellowAccent,
            onPressed: () {
              // Code to dismiss
            },
          )
        : null,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
