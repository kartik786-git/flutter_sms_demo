import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'student_service.dart';
import 'class_service.dart';

class DashboardScreen extends StatelessWidget {
    const DashboardScreen({super.key});
      @override
  Widget build(BuildContext context) {
 final studentCount = context.watch<StudentService>().students.length;
    final classCount = context.watch<ClassService>().classes.length;
 return Container(
      color: const Color(0xFFF8F6FF),
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 500;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  colors: [Colors.deepPurple, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(rect),
                child: const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: isMobile
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          key: const ValueKey('row-mobile'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _ModernInfoCard(
                                label: 'Students',
                                count: studentCount,
                                icon: Icons.people,
                                color: Colors.deepPurple,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _ModernInfoCard(
                                label: 'Classes',
                                count: classCount,
                                icon: Icons.class_,
                                color: Colors.orange,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Row(
                        key: const ValueKey('row'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ModernInfoCard(
                            label: 'Students',
                            count: studentCount,
                            icon: Icons.people,
                            color: Colors.deepPurple,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          const SizedBox(width: 32),
                          _ModernInfoCard(
                            label: 'Classes',
                            count: classCount,
                            icon: Icons.class_,
                            color: Colors.orange,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB75E), Color(0xFFED8F03)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModernInfoCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  const _ModernInfoCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: 110,
      constraints: const BoxConstraints(maxWidth: 140, minWidth: 90),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(icon, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 18),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}