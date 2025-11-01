import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../sos_waiting_view_model.dart';
import 'package:resqapp/components/radiant_circle_button.dart';
import 'package:resqapp/theme/theme_app.dart';

class SOSWaitingTimerSection extends StatelessWidget {
  const SOSWaitingTimerSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveFontSize = screenWidth * 0.08; // Scales with screen width
    
    return Consumer<SOSWaitingViewModel>(
      builder: (context, viewModel, child) {
        return RadiantCircleButton(
          mainColor: Color(theme.colors.primary),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              viewModel.formattedTime,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w900,
                fontSize: responsiveFontSize.clamp(24.0, 32.0),
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
