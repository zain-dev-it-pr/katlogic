import 'dart:ui';
import 'package:flutter/material.dart';

class NeonChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const NeonChatBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final neonColor =
    isUser ? Colors.cyanAccent : Colors.purpleAccent;

    return Align(
      alignment:
      isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),

                // 🌌 Transparent glass background
                color: neonColor.withOpacity(0.08),

                // 💡 Neon Border
                border: Border.all(
                  color: neonColor.withOpacity(0.7),
                  width: 1.5,
                ),

                // ✨ Neon Glow
                boxShadow: [
                  BoxShadow(
                    color: neonColor.withOpacity(0.6),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: neonColor.withOpacity(0.3),
                    blurRadius: 35,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
