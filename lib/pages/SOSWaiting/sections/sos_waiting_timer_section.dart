import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../sos_waiting_view_model.dart';
import 'package:resqapp/components/radiant_circle_button.dart';
import 'package:resqapp/theme/theme_app.dart';

class SOSWaitingTimerSection extends StatelessWidget {
  const SOSWaitingTimerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ResQTheme();
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveFontSize = screenWidth * 0.08;
    
    return Consumer<SOSWaitingViewModel>(
      builder: (context, viewModel, child) {
        final circleColor = viewModel.isResponseTeamAssigned
            ? Color(0xFFF1C8C8)
            : theme.colors.primary;

        final textColor = viewModel.isResponseTeamAssigned
            ? theme.colors.primary
            : Colors.white;
        
        return RadiantCircleButton(
          mainColor: circleColor,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              viewModel.formattedTime,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w900,
                fontSize: responsiveFontSize.clamp(24.0, 32.0),
                color: textColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
