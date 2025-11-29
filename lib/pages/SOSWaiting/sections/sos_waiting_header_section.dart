import 'package:flutter/material.dart';

class SOSWaitingHeaderSection extends StatelessWidget {
  final bool isResponseTeamAssigned;
  
  const SOSWaitingHeaderSection({
    Key? key,
    this.isResponseTeamAssigned = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveFontSize = screenWidth * 0.06;
    
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Center(
            child: Text(
              isResponseTeamAssigned
                  ? 'Bala bantuan sedang menuju ketempat anda'
                  : 'Menunggu bala bantuan',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: responsiveFontSize.clamp(18.0, 24.0),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SizedBox(width: 48),
      ],
    );
  }
}
