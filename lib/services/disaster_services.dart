import 'dart:async';
import 'dart:developer' as developer;

import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resqapp/components/disaster_detail_modal.dart';
import '../models/supabase_models.dart';

class DisasterServices {
  static final SupabaseClient _client = Supabase.instance.client;
  static final DateFormat _disasterDateFormatter = DateFormat(
    'd MMMM yyyy, HH:mm:ss',
    'id_ID',
  );

  // ==================== Disasters ====================

  /// Get all disasters that occurred today
  static Future<List<Disaster>> getFilteredDisasters() async {
    try {
      final startOfDayMs = _getStartOfDayTimestamp(dayRange: 15);
      final response = await _client
          .from('disasters')
          .select()
          .gte('occurred_at', startOfDayMs)
          .order('occurred_at', ascending: false);
      return (response as List).map((json) => Disaster.fromJson(json)).toList();
    } catch (e) {
      developer.log('Error getting disasters: $e');
      return [];
    }
  }

  /// Get all disasters (for debugging - not filtered by date)
  static Future<List<Disaster>> getAllDisasters() async {
    try {
      final response = await _client
          .from('disasters')
          .select()
          .order('occurred_at', ascending: false)
          .limit(100);

      return (response as List).map((json) => Disaster.fromJson(json)).toList();
    } catch (e) {
      developer.log('Error getting disasters: $e');
      return [];
    }
  }

  // ==================== Formatting Methods ====================

  static String formatDisasterDate(double? timestamp) {
    if (timestamp == null) return 'Tidak tersedia';
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(
        timestamp.toInt() * 1000,
      );
      return '${_disasterDateFormatter.format(dateTime)} WIB';
    } catch (_) {
      return 'Tidak tersedia';
    }
  }

  static String formatSOSReportTime(double? timestamp) {
    if (timestamp == null || timestamp == 0) return '-';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    final time =
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    final date =
        "${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}";
    return "$time, $date";
  }

  static String formatMagnitude(double? magnitude) {
    return magnitude != null
        ? '${magnitude.toStringAsFixed(2)} SR'
        : 'Tidak tersedia';
  }

  static String getTsunamiPotential(double? magnitude) {
    if (magnitude == null) return 'Tidak Berpotensi';
    return magnitude >= 7.0 ? 'Berpotensi' : 'Tidak Berpotensi';
  }

  static String formatDepth(String? depth) {
    return (depth == null || depth.isEmpty) ? 'Tidak tersedia' : depth;
  }

  static Future<void> launchShakeMap(String? url) async {
    if (url == null || url.isEmpty) {
      throw const DisasterActionException('Peta guncangan tidak tersedia');
    }
    try {
      final uri = Uri.parse(url);
      if (!await canLaunchUrl(uri)) {
        throw const DisasterActionException(
          'Tidak dapat membuka peta guncangan',
        );
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (e is DisasterActionException) rethrow;
      throw DisasterActionException('Error: ${e.toString()}');
    }
  }

  static int _getStartOfDayTimestamp({required int dayRange}) {
    final now = DateTime.now();

    final targetDate = now.subtract(Duration(days: dayRange));

    final startOfDay = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    final miliEpoch = startOfDay.millisecondsSinceEpoch;
    final timestamp = (miliEpoch / 1000).round();

    return timestamp;
  }
}
