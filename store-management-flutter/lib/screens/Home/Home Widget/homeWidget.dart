// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class HomeWidget extends StatelessWidget {
  HomeWidget({super.key, @required this.name, @required this.imagepath});
  String? name;
  String? imagepath;

  // Role-based gradient palettes
  static const _darkGradients = [
    [Color(0xFF1E3A5F), Color(0xFF2D5F8A)],
    [Color(0xFF1B4332), Color(0xFF2D6A4F)],
    [Color(0xFF4A1942), Color(0xFF7B2D8B)],
    [Color(0xFF3D1A00), Color(0xFF8B4513)],
    [Color(0xFF0D3D56), Color(0xFF1A6B8A)],
    [Color(0xFF2D1B69), Color(0xFF553C9A)],
    [Color(0xFF1A3A1A), Color(0xFF2E7D32)],
  ];

  static const _lightGradients = [
    [Color(0xFF42A5F5), Color(0xFF1E88E5)],
    [Color(0xFF66BB6A), Color(0xFF43A047)],
    [Color(0xFFAB47BC), Color(0xFF8E24AA)],
    [Color(0xFFFFA726), Color(0xFFFB8C00)],
    [Color(0xFF26C6DA), Color(0xFF00ACC1)],
    [Color(0xFF7E57C2), Color(0xFF5E35B1)],
    [Color(0xFF9CCC65), Color(0xFF7CB342)],
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradients = isDark ? _darkGradients : _lightGradients;

    // Pick a gradient based on name hash for consistency
    final hash = (name ?? '').hashCode.abs() % gradients.length;
    final grad = gradients[hash];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: grad,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: grad[1].withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Image.asset(
                      imagepath!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
