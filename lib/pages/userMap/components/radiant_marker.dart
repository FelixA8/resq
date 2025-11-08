import 'package:flutter/material.dart';

class RadiantMarker extends StatefulWidget {
  final Widget child;
  final Color color;
  const RadiantMarker({Key? key, required this.child, required this.color}) : super(key: key);

  @override
  State<RadiantMarker> createState() => _RadiantMarkerState();
}

class _RadiantMarkerState extends State<RadiantMarker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Radiance glow
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_animation.value * 0.55),
                    blurRadius: 0 * _animation.value,
                    spreadRadius: 20 * _animation.value,
                  ),
                ],
              ),
            ),
            // Main marker image
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}