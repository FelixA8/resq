import 'package:flutter/material.dart';
import 'package:resqapp/theme/theme_app.dart';

class RadiantCircleButton extends StatefulWidget {
  final Color mainColor;
  final Widget child;
  final VoidCallback? onPressed;
  const RadiantCircleButton({Key? key, required this.mainColor, required this.child, this.onPressed}) : super(key: key);

  @override
  State<RadiantCircleButton> createState() => _RadiantCircleButtonState();
}

class _RadiantCircleButtonState extends State<RadiantCircleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final theme = ResQTheme();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Responsive sizing based on screen width (use smaller dimension to ensure it fits)
    final minDimension = screenWidth < screenHeight ? screenWidth : screenHeight;
    
    // Responsive sizes - scale with screen but maintain aspect ratios
    final outerSize = (minDimension * 0.6).clamp(200.0, 240.0);
    final middleSize = (minDimension * 0.525).clamp(175.0, 210.0);
    final innerSize = (minDimension * 0.45).clamp(150.0, 180.0);
    final borderWidth = (minDimension * 0.04).clamp(12.0, 16.0);
    
    return Center(
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outermost radiating circle (animated)
                Container(
                  width: outerSize,
                  height: outerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Color(theme.colors.primary).withOpacity(_animation.value * 0.18),
                        blurRadius: 10 * _animation.value,
                        spreadRadius: 5 * _animation.value,
                      ),
                    ],
                  ),
                ),
                // Middle pink circle (static)
                Container(
                  width: middleSize,
                  height: middleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF1C8C8), // Pink
                  ),
                ),
                // Innermost main button
                Container(
                  width: innerSize,
                  height: innerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.mainColor,
                    boxShadow: [
                      BoxShadow(
                        color: widget.mainColor.withOpacity(_animation.value * 0.25),
                        blurRadius: 48 * _animation.value,
                        spreadRadius: 16 * _animation.value,
                      ),
                    ],
                    border: Border.all(
                      color: widget.mainColor.withOpacity(0.15),
                      width: borderWidth,
                    ),
                  ),
                  child: Center(child: widget.child),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
