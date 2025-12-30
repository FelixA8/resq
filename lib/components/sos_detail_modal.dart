import 'package:flutter/material.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'package:resqapp/components/confirmation_button.dart';

class SOSDetailModal extends StatefulWidget {
  final SosEvent sosEvent;
  final Future<ResqUser?> Function(String) onFetchUser;
  final Future<String> Function(SosEvent) onFetchAddress;
  final String Function(double?) formatReportTime;
  final VoidCallback onShowRoute;
  final bool isNavigating;
  final double distanceKm;
  final VoidCallback? onCancelRoute;
  final String? currentResponseTeamId;
  final bool isRouteButtonEnabled;

  const SOSDetailModal({
    super.key,
    required this.sosEvent,
    required this.onFetchUser,
    required this.onFetchAddress,
    required this.formatReportTime,
    required this.onShowRoute,
    this.isNavigating = false,
    this.distanceKm = 0.0,
    this.onCancelRoute,
    this.currentResponseTeamId,
    this.isRouteButtonEnabled = true,
  });

  @override
  State<SOSDetailModal> createState() => _SOSDetailModalState();
}

class _SOSDetailModalState extends State<SOSDetailModal> {
  ResqUser? _user;
  String? _address;
  bool _isLoadingUser = true;
  bool _isLoadingAddress = true;
  static const theme = ResQTheme();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.sosEvent.userId != null) {
      setState(() => _isLoadingUser = true);
      try {
        final user = await widget.onFetchUser(widget.sosEvent.userId!);
        if (!mounted) return;
        setState(() {
          _user = user;
          _isLoadingUser = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _isLoadingUser = false);
      }
    } else {
      setState(() => _isLoadingUser = false);
    }

    setState(() => _isLoadingAddress = true);
    try {
      final address = await widget.onFetchAddress(widget.sosEvent);
      if (!mounted) return;
      setState(() {
        _address = address;
        _isLoadingAddress = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _address = 'Lokasi tidak tersedia';
        _isLoadingAddress = false;
      });
    }
  }

  Widget _buildHandleBar() => Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _isLoadingUser
            ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
            )
            : Text(
              _user?.username ?? 'Tidak diketahui',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              ),
            ),

        const SizedBox(height: 4),

        _isLoadingAddress
            ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colors.primary),
            )
            : Text(
              _address ?? 'Lokasi tidak tersedia',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
      ],
    ),
  );

  Widget _buildInfoRow({
    required String iconPath,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 1.5,
            color: Colors.grey.shade200,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 30,
                height: 30,
                color: theme.colors.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: theme.colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShowRouteButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ConfirmationButton(
      onPressed: widget.onShowRoute,
      isEnabled: widget.isRouteButtonEnabled,
      text: 'Tunjukkan Rute',
    ),
  );

  Widget _buildNavigatingUI() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${widget.distanceKm.toStringAsFixed(2)} Km',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: theme.colors.primary,
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: 65,
          child: ElevatedButton(
            onPressed: widget.onCancelRoute,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    _buildHeader(),

                    const SizedBox(height: 8),

                    _buildInfoRow(
                      iconPath: 'assets/images/icons/time.png',
                      label: 'Waktu Pelaporan',
                      value: widget.formatReportTime(widget.sosEvent.pressedAt),
                    ),

                    _buildInfoRow(
                      iconPath: 'assets/images/icons/phone.png',
                      label: 'Nomor Telepon',
                      value: _user?.phoneNumber ?? 'Tidak tersedia',
                    ),

                    const SizedBox(height: 30),

                    if (widget.isNavigating)
                      _buildNavigatingUI()
                    else
                      _buildShowRouteButton(),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! > 8) {
                  Navigator.pop(context); // pull down to dismiss
                }
              },
              child: _buildHandleBar(),
            ),
          ),
        ],
      ),
    );
  }
}
