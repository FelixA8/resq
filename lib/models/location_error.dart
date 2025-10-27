enum LocationErrorType {
  permissionDenied,
  locationServiceDisabled,
  timeout,
  unableToGetLocation,
  serviceNotResponding,
  generic,
}

class LocationError {
  final LocationErrorType type;
  final String message;
  final bool isRetryable;
  final bool requiresUserAction;

  const LocationError({
    required this.type,
    required this.message,
    required this.isRetryable,
    required this.requiresUserAction,
  });

  factory LocationError.permissionDenied() {
    return const LocationError(
      type: LocationErrorType.permissionDenied,
      message:
          'Izin lokasi ditolak. Harap berikan izin lokasi untuk menggunakan fitur ini.',
      isRetryable: true,
      requiresUserAction: true,
    );
  }

  factory LocationError.locationServiceDisabled() {
    return const LocationError(
      type: LocationErrorType.locationServiceDisabled,
      message:
          'Location services are disabled. Please enable location services in your device settings.',
      isRetryable: true,
      requiresUserAction: true,
    );
  }

  factory LocationError.timeout() {
    return const LocationError(
      type: LocationErrorType.timeout,
      message:
          'Location request timed out. This might be due to poor GPS signal or network issues. Please try again or check your location settings.',
      isRetryable: true,
      requiresUserAction: true,
    );
  }

  factory LocationError.unableToGetLocation() {
    return const LocationError(
      type: LocationErrorType.unableToGetLocation,
      message:
          'Unable to determine your location. Please ensure GPS is enabled and try again.',
      isRetryable: true,
      requiresUserAction: true,
    );
  }

  factory LocationError.serviceNotResponding() {
    return const LocationError(
      type: LocationErrorType.serviceNotResponding,
      message:
          'Location services are not responding. Please check your GPS settings and try again.',
      isRetryable: true,
      requiresUserAction: true,
    );
  }

  factory LocationError.quickLocationFailed() {
    return const LocationError(
      type: LocationErrorType.generic,
      message: 'Gagal mendeteksi lokasi, periksa pengaturan anda!',
      isRetryable: true,
      requiresUserAction: true,
    );
  }

  factory LocationError.generic(String message) {
    return LocationError(
      type: LocationErrorType.generic,
      message: message,
      isRetryable: true,
      requiresUserAction: false,
    );
  }

  @override
  String toString() => message;
}

