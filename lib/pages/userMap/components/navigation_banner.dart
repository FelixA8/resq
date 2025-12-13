import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/userMap/user_map_view_model.dart';
import 'package:resqapp/theme/theme_app.dart';

class NavigationBanner extends StatelessWidget {
  const NavigationBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = ResQTheme();
    
    return GetX<UserMapViewModel>(
      builder: (controller) {
        if (!controller.isNavigating.value) {
          return SizedBox.shrink();
        }
        
        // Show arrival UI when user has arrived
        if (controller.hasArrived.value) {
          return _buildArrivalBanner(controller, theme);
        }
        
        // Show navigation UI when navigating
        return _buildNavigationBanner(controller, theme);
      },
    );
  }

  Widget _buildArrivalBanner(UserMapViewModel controller, ResQTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkmark Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 32,
            ),
          ),
          SizedBox(width: 12),
          // Arrival Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You have arrived',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Anda telah sampai di lokasi',
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
          SizedBox(width: 8),
          // Finish Button
          ElevatedButton(
            onPressed: () => controller.completeNavigation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green.shade600,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: Text(
              'Finish',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBanner(UserMapViewModel controller, ResQTheme theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Turn Direction Icon
          _buildTurnIcon(controller.turnType.value, theme),
          SizedBox(width: 12),
          // Navigation Instructions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Next turn instruction
                if (controller.currentInstruction.value.isNotEmpty)
                  Text(
                    controller.currentInstruction.value,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 2),
                // Total distance remaining
                Text(
                  'Jarak menuju lokasi: ${_formatDistance(controller.distanceToDestination.value * 1000)}',
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
    );
  }

  Widget _buildTurnIcon(String turnType, ResQTheme theme) {
    IconData iconData;
    
    switch (turnType.toLowerCase()) {
      case 'left':
        iconData = Icons.turn_left;
        break;
      case 'right':
        iconData = Icons.turn_right;
        break;
      case 'straight':
        iconData = Icons.arrow_upward;
        break;
      case 'uturn':
        iconData = Icons.u_turn_left;
        break;
      case 'roundabout':
        iconData = Icons.roundabout_left;
        break;
      default:
        iconData = Icons.navigation;
    }
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: theme.colors.primary,
        size: 28,
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }
}
