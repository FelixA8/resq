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
                  width: 240,
                  height: 240,
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
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF1C8C8), // Pink
                  ),
                ),
                // Innermost main button
                Container(
                  width: 180,
                  height: 180,
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
                      width: 16,
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
