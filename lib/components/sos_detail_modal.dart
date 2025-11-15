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

  const SOSDetailModal({
    Key? key,
    required this.sosEvent,
    required this.onFetchUser,
    required this.onFetchAddress,
    required this.formatReportTime,
    required this.onShowRoute,
  }) : super(key: key);

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
    // Load user info
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

    // Load address
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

  // -----------------------------
  // UI Builders
  // -----------------------------
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
            // Username
            _isLoadingUser
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(theme.colors.primary),
                    ),
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
            // Report Location
            _isLoadingAddress
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(theme.colors.primary),
                    ),
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
                color: Color(theme.colors.primary),
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
                        color: Color(theme.colors.primary),
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
          isEnabled: true,
          text: 'Tunjukkan Rute',
        ),
      );

  // -----------------------------
  // Build Method
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          // Scrollable content
          Padding(
            padding: const EdgeInsets.only(top: 18), // spacing below handle bar
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Header (Username and Location)
                    _buildHeader(),
                    const SizedBox(height: 8),
                    // Report Time
                    _buildInfoRow(
                      iconPath: 'assets/images/icons/time.png',
                      label: 'Waktu Pelaporan',
                      value: widget.formatReportTime(widget.sosEvent.pressedAt),
                    ),
                    // Phone Number
                    _buildInfoRow(
                      iconPath: 'assets/images/icons/phone.png',
                      label: 'Nomor Telepon',
                      value: _user?.phoneNumber ?? 'Tidak tersedia',
                    ),
                    const SizedBox(height: 30),
                    // Show Route Button
                    _buildShowRouteButton(),
                  ],
                ),
              ),
            ),
          ),

          // Fixed handle bar
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

