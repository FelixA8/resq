import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqapp/theme/theme_app.dart';

class LocationHelper {
  static const LatLng defaultLocation = LatLng(-6.2088, 106.8456);
  static const theme = ResQTheme();

  static Future<LocationResult> getCurrentLocation() async {
    try {
      bool locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationServiceEnabled) {
        Get.snackbar(
          'Layanan Lokasi Nonaktif',
          'Mohon aktifkan Lokasi Anda untuk menggunakan fitur ini',
          snackPosition: SnackPosition.BOTTOM,
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 2),
          isDismissible: true,
        );
        return LocationResult(
          location: defaultLocation,
          hasPermission: false,
          error: 'Location service disabled',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Izin Ditolak',
            'Izin lokasi diperlukan untuk menampilkan posisi Anda di peta',
            snackPosition: SnackPosition.BOTTOM,
            animationDuration: Duration(milliseconds: 500),
            duration: Duration(seconds: 2),
            isDismissible: true,
          );
          return LocationResult(
            location: defaultLocation,
            hasPermission: false,
            error: 'Permission denied',
          );
        }
      }

      return await _getLocationAfterPermission();
    } catch (e) {
      Get.snackbar(
        'Kesalahan Lokasi',
        'Gagal menginisialisasi lokasi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return LocationResult(
        location: defaultLocation,
        hasPermission: false,
        error: e.toString(),
      );
    }
  }

  static Future<LocationResult> _getLocationAfterPermission() async {
    try {
      Position? lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        return LocationResult(
          location: LatLng(
            lastKnownPosition.latitude,
            lastKnownPosition.longitude,
          ),
          hasPermission: true,
        );
      }

      return await _getCurrentLocation();
    } catch (e) {
      return await _getCurrentLocation();
    }
  }

  static Future<LocationResult> _getCurrentLocation() async {
    try {
      bool locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationServiceEnabled) {
        Get.snackbar(
          'Layanan Lokasi Nonaktif',
          'Mohon aktifkan Lokasi Anda untuk menggunakan fitur ini',
          snackPosition: SnackPosition.BOTTOM,
          animationDuration: Duration(milliseconds: 500),
          duration: Duration(seconds: 2),
          isDismissible: true,
        );
        return LocationResult(
          location: defaultLocation,
          hasPermission: false,
          error: 'Location service disabled',
        );
      }

      Position? position;

      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        );
      } catch (e) {
        throw Exception('Location retrieval methods failed: ${e.toString()}');
      }

      return LocationResult(
        location: LatLng(position.latitude, position.longitude),
        hasPermission: true,
      );
    } catch (e) {
      String errorMessage = 'Layanan Lokasi Tidak Merespons';
      Color backgroundColor = theme.colors.primary;

      if (e.toString().contains('timeout')) {
        errorMessage = 'Tidak dapat mendapatkan lokasi. Silakan coba lagi.';
      } else if (e.toString().contains('permission')) {
        errorMessage =
            'Izin lokasi diperlukan untuk menampilkan posisi Anda di peta';
      } else if (e.toString().contains(
        'Unable to get current or last known location',
      )) {
        errorMessage = 'Gagal mendapatkan lokasi terkini. Silakan coba lagi.';
      }

      Get.snackbar(
        'Kesalahan Lokasi',
        errorMessage,
        backgroundColor: backgroundColor,
        colorText: Color(0xFFFFFFFF),
        snackPosition: SnackPosition.BOTTOM,
        animationDuration: Duration(milliseconds: 500),
        duration: Duration(seconds: 2),
        isDismissible: true,
      );

      return LocationResult(
        location: defaultLocation,
        hasPermission: false,
        error: e.toString(),
      );
    }
  }

  /// Get current location without showing error messages (for refresh operations)
  static Future<LocationResult> getCurrentLocationSilent() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );

      return LocationResult(
        location: LatLng(position.latitude, position.longitude),
        hasPermission: true,
      );
    } catch (e) {
      return LocationResult(
        location: defaultLocation,
        hasPermission: false,
        error: e.toString(),
      );
    }
  }

  /// Get address details from coordinates using reverse geocoding
  static Future<LocationDetailResult> getLocationDetails(
    LatLng coordinates,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        String city =
            placemark.locality ??
            placemark.administrativeArea ??
            placemark.subAdministrativeArea ??
            'Kota Tidak Diketahui';

        List<String> addressParts = [];

        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }
        if (placemark.subLocality != null &&
            placemark.subLocality!.isNotEmpty) {
          addressParts.add(placemark.subLocality!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }
        if (placemark.administrativeArea != null &&
            placemark.administrativeArea!.isNotEmpty) {
          addressParts.add(placemark.administrativeArea!);
        }

        String locationDetail =
            addressParts.isNotEmpty
                ? addressParts.join(', ')
                : 'Lat: ${coordinates.latitude.toStringAsFixed(6)}, Lng: ${coordinates.longitude.toStringAsFixed(6)}';

        return LocationDetailResult(
          city: city,
          locationDetail: locationDetail,
          success: true,
        );
      } else {
        return LocationDetailResult(
          city: 'Kota Tidak Diketahui',
          locationDetail:
              'Lat: ${coordinates.latitude.toStringAsFixed(6)}, Lng: ${coordinates.longitude.toStringAsFixed(6)}',
          success: false,
          error: 'Alamat tidak ditemukan untuk lokasi ini',
        );
      }
    } catch (e) {
      return LocationDetailResult(
        city: 'Kota Tidak Diketahui',
        locationDetail:
            'Lat: ${coordinates.latitude.toStringAsFixed(6)}, Lng: ${coordinates.longitude.toStringAsFixed(6)}',
        success: false,
        error: e.toString(),
      );
    }
  }
}

class LocationResult {
  final LatLng location;
  final bool hasPermission;
  final String? error;

  LocationResult({
    required this.location,
    required this.hasPermission,
    this.error,
  });
}

class LocationDetailResult {
  final String city;
  final String locationDetail;
  final bool success;
  final String? error;

  LocationDetailResult({
    required this.city,
    required this.locationDetail,
    required this.success,
    this.error,
  });
}
