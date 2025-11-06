import 'package:flutter/material.dart';
import 'models/sos_report_item.dart';

class ResponseTeamSOSReportViewModel extends ChangeNotifier {
  List<SOSReportItem> _sosReports = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentUnitId = '#Unit305'; // Default unit ID
  String _currentLocation = 'Tangerang Selatan'; // Default location

  // Getters
  List<SOSReportItem> get sosReports => _sosReports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentUnitId => _currentUnitId;
  String get currentLocation => _currentLocation;

  ResponseTeamSOSReportViewModel() {
    _loadSOSReports();
  }

  /// Load SOS reports from data source
  Future<void> _loadSOSReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call to fetch SOS reports
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Mock data for demonstration
      _sosReports = [
        SOSReportItem(
          reportId: '1',
          userName: 'John Doe',
          phoneNumber: '+62 813 3832 7789',
          distanceKm: 12.6,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          locationLat: -6.2088,
          locationLng: 106.8456,
        ),
        SOSReportItem(
          reportId: '2',
          userName: 'John Doe',
          phoneNumber: '+62 813 3832 7789',
          distanceKm: 13.6,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          assignedUnitId: '#403',
          locationLat: -6.2188,
          locationLng: 106.8556,
        ),
        SOSReportItem(
          reportId: '3',
          userName: 'John Doe',
          phoneNumber: '+62 813 3832 7789',
          distanceKm: 14.9,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          assignedUnitId: '#403',
          locationLat: -6.2288,
          locationLng: 106.8656,
        ),
        SOSReportItem(
          reportId: '4',
          userName: 'John Doe',
          phoneNumber: '+62 813 3832 7789',
          distanceKm: 15.1,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          locationLat: -6.2388,
          locationLng: 106.8756,
        ),
        SOSReportItem(
          reportId: '4',
          userName: 'John Doe',
          phoneNumber: '+62 813 3832 7789',
          distanceKm: 15.1,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          locationLat: -6.2388,
          locationLng: 106.8756,
        ),
        SOSReportItem(
          reportId: '4',
          userName: 'John Doe',
          phoneNumber: '+62 813 3832 7789',
          distanceKm: 15.1,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          locationLat: -6.2388,
          locationLng: 106.8756,
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load SOS reports: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Refresh SOS reports list
  Future<void> refreshReports() async {
    await _loadSOSReports();
  }

  /// Assign a report to this unit
  Future<void> assignReport(String reportId) async {
    try {
      // TODO: Replace with actual API call to assign report
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _sosReports.indexWhere((report) => report.reportId == reportId);
      if (index != -1) {
        _sosReports[index] = SOSReportItem(
          reportId: _sosReports[index].reportId,
          userName: _sosReports[index].userName,
          phoneNumber: _sosReports[index].phoneNumber,
          distanceKm: _sosReports[index].distanceKm,
          timestamp: _sosReports[index].timestamp,
          assignedUnitId: _currentUnitId,
          locationLat: _sosReports[index].locationLat,
          locationLng: _sosReports[index].locationLng,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to assign report: ${e.toString()}';
      notifyListeners();
    }
  }

  /// View report on map
  void viewOnMap(String reportId) {
    // TODO: Navigate to map view with report location
    // This will be implemented when map navigation is ready
  }

  /// Format timestamp for display
  String formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

