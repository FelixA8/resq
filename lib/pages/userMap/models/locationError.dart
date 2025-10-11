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
      isRetryable: false,
      requiresUserAction: false,
    );
  }

  factory LocationError.locationServiceDisabled() {
    return const LocationError(
      type: LocationErrorType.locationServiceDisabled,
      message:
          'Gagal mendeteksi lokasi, periksa pengaturan anda!',
      isRetryable: false,
      requiresUserAction: false,
    );
  }

  factory LocationError.timeout() {
    return const LocationError(
      type: LocationErrorType.timeout,
      message:
          'Gagal mendeteksi lokasi, periksa pengaturan anda!',
      isRetryable: false,
      requiresUserAction: false,
    );
  }

  factory LocationError.unableToGetLocation() {
    return const LocationError(
      type: LocationErrorType.unableToGetLocation,
      message:
          'Gagal mendeteksi lokasi, periksa pengaturan anda!',
      isRetryable: false,
      requiresUserAction: false,
    );
  }

  factory LocationError.serviceNotResponding() {
    return const LocationError(
      type: LocationErrorType.serviceNotResponding,
      message:
          'Gagal mendeteksi lokasi, periksa pengaturan anda!',
      isRetryable: false,
      requiresUserAction: false,
    );
  }

  factory LocationError.quickLocationFailed() {
    return const LocationError(
      type: LocationErrorType.generic,
      message: 'Gagal mendeteksi lokasi, periksa pengaturan anda!',
      isRetryable: false,
      requiresUserAction: false,
    );
  }

  factory LocationError.generic(String message) {
    return LocationError(
      type: LocationErrorType.generic,
      message: message,
      isRetryable: false,
      requiresUserAction: false,
    );
  }

  @override
  String toString() => message;
}


