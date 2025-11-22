import 'package:flutter/material.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/theme/theme_app.dart';

class DisasterDetailModal extends StatefulWidget {
  final Disaster disaster;
  final Future<String> Function(Disaster) onFetchAddress;
  final Future<void> Function(Disaster) onDownloadShakeMap;
  final String Function(double?) formatDate;
  final String Function(double?) formatMagnitude;
  final String Function(double?) getTsunamiPotential;
  final String Function(String?) formatDepth;

  const DisasterDetailModal({
    Key? key,
    required this.disaster,
    required this.onFetchAddress,
    required this.onDownloadShakeMap,
    required this.formatDate,
    required this.formatMagnitude,
    required this.getTsunamiPotential,
    required this.formatDepth,
  }) : super(key: key);

  @override
  State<DisasterDetailModal> createState() => _DisasterDetailModalState();
}

class _DisasterDetailModalState extends State<DisasterDetailModal> {
  String? _address;
  bool _isLoadingAddress = true;
  static const theme = ResQTheme();

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    setState(() => _isLoadingAddress = true);

    try {
      final address = await widget.onFetchAddress(widget.disaster);
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

  Future<void> _downloadShakeMap() async {
    try {
      await widget.onDownloadShakeMap(widget.disaster);
    } on DisasterActionException catch (e) {
      _showSnackBar(e.message);
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildDivider() => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 1.5,
        color: Colors.grey.shade200,
      );

  Widget _buildInfoRow({
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // center vertically
      children: [
        // Icon section
        Image.asset(
          icon,
          width: 30,
          height: 30,
          color: theme.colors.primary,
        ),
        const SizedBox(width: 16),

        // Text section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // prevents extra vertical space
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
    );
  }

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

                    // Title
                    _buildHeader(),
                    const SizedBox(height: 18),

                    // Download Shake Map
                    _buildDownloadLink(),
                    const SizedBox(height: 8),

                    // Disaster Info List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildDivider(),
                          _buildInfoRow(
                            icon: 'assets/images/icons/earthquake-scale.png',
                            label: 'Kekuatan Gempa',
                            value: widget.formatMagnitude(widget.disaster.magnitude),
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            icon: 'assets/images/icons/date.png',
                            label: 'Waktu Kejadian',
                            value: widget.formatDate(widget.disaster.occurredAt),
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            icon: 'assets/images/icons/tsunami.png',
                            label: 'Potensi Terjadinya Tsunami',
                            value: widget.getTsunamiPotential(widget.disaster.magnitude),
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            icon: 'assets/images/icons/depth.png',
                            label: 'Kedalaman',
                            value: widget.formatDepth(widget.disaster.depth),
                          ),
                        ],
                      ),
                    ),
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

  // -----------------------------
  // Subcomponents
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
            const Text(
              'Gempa Bumi',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            _isLoadingAddress
                ? CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(theme.colors.primary),
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

  Widget _buildDownloadLink() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: _downloadShakeMap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unduh Peta Guncangan',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: theme.colors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.download,
                size: 16,
                color: theme.colors.primary,
              ),
            ],
          ),
        ),
      );
}

class DisasterActionException implements Exception {
  final String message;

  const DisasterActionException(this.message);

  @override
  String toString() => message;
}

