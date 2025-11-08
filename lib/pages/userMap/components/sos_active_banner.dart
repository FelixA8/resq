import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqapp/pages/userMap/userMapViewModel.dart';
import 'package:resqapp/pages/SOSWaiting/sos_waiting_view.dart';
import 'package:resqapp/pages/SOSWaiting/sos_waiting_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'dart:math' as math;

class SOSActiveBanner extends StatelessWidget {
  const SOSActiveBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = ResQTheme();
    return Consumer<UserMapViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isSOSActive) {
          return SizedBox.shrink();
        }
        
        return GestureDetector(
          onTap: () {
            // Navigate to SOS waiting view with existing ViewModel
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider<UserMapViewModel>.value(
                      value: viewModel,
                    ),
                    ChangeNotifierProvider<SOSWaitingViewModel>.value(
                      value: viewModel.sosWaitingViewModel!,
                    ),
                  ],
                  child: SOSWaitingView(viewModel: viewModel.sosWaitingViewModel),
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(theme.colors.primary),
            ),
            child: Row(
              children: [
                // Animated SOS Icon Circle
                AnimatedSOSCircle(),
                SizedBox(width: 12),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Menunggu response team',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tunggu bantuan datang dalam waktu dekat!',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimatedSOSCircle extends StatefulWidget {
  const AnimatedSOSCircle({Key? key}) : super(key: key);

  @override
  State<AnimatedSOSCircle> createState() => _AnimatedSOSCircleState();
}

class _AnimatedSOSCircleState extends State<AnimatedSOSCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final theme = ResQTheme();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(50, 50),
          painter: RotatingBorderPainter(
            progress: _controller.value,
            borderColor: Colors.white,
          ),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFFF1C8C8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'SOS',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Color(theme.colors.primary),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class RotatingBorderPainter extends CustomPainter {
  final double progress;
  final Color borderColor;

  RotatingBorderPainter({
    required this.progress,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 3.0;
    final sweepAngle = math.pi * 1.2; // 120 degrees arc
    
    // Calculate the start angle based on progress (0 to 2π)
    final startAngle = -math.pi / 2 + (progress * 2 * math.pi);
    
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Draw the rotating arc border
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(RotatingBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

