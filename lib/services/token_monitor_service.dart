import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/services/shared_preferences_service.dart';

class TokenMonitorService {
  static Timer? _timer;
  static ValueNotifier<bool> tokenExpiredNotifier = ValueNotifier<bool>(false);
  static bool _isMonitoring = false;
  static bool _dialogShown = false;

  //  Start monitoring token expiry
  static void startMonitoring() {
    if (_isMonitoring) {
      print('⚠️ [TOKEN_MONITOR] Already monitoring, skipping...');
      return;
    }

    stopMonitoring(); // Clear existing timer
    _isMonitoring = true;
    _dialogShown = false; // Reset dialog flag

    print('👀 [TOKEN_MONITOR] Starting token monitoring...');

    // Check every hour
    _timer = Timer.periodic(const Duration(hours: 1), (timer) async {
      final isExpired = await SharedPreferencesService.isTokenExpired();

      if (isExpired && !_dialogShown) {
        print('❌ [TOKEN_MONITOR] Token expired detected!');
        tokenExpiredNotifier.value = true;
        _dialogShown = true; // Prevent multiple triggers
        stopMonitoring();

        // Clear auth data
        await SharedPreferencesService.clearAuthData();
      } else if (!isExpired) {
        final remaining =
            await SharedPreferencesService.getTokenRemainingTime();
        if (remaining != null) {
          final hours = remaining.inHours;
          final minutes = (remaining.inMinutes % 60);
          print('⏰ [TOKEN_MONITOR] Token valid for ${hours}h ${minutes}m');
        }
      }
    });
    _checkTokenImmediately();
  }

  static Future<void> _checkTokenImmediately() async {
    final isExpired = await SharedPreferencesService.isTokenExpired();

    if (isExpired && !_dialogShown) {
      print('❌ [TOKEN_MONITOR] Token already expired on start!');
      tokenExpiredNotifier.value = true;
      _dialogShown = true;
      stopMonitoring();
      await SharedPreferencesService.clearAuthData();
    } else if (!isExpired) {
      final remaining = await SharedPreferencesService.getTokenRemainingTime();
      if (remaining != null) {
        print('✅ [TOKEN_MONITOR] Token valid for ${remaining.inHours} hours');
      }
    }
  }

  // Stop monitoring
  static void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    _isMonitoring = false;
    print('🛑 [TOKEN_MONITOR] Monitoring stopped');
  }

  //  Reset monitoring (untuk login baru)
  static void resetMonitoring() {
    print('🔄 [TOKEN_MONITOR] Resetting monitoring state...');
    stopMonitoring();
    tokenExpiredNotifier.value = false; //  Reset notifier
    _dialogShown = false; //  Reset dialog flag
    _isMonitoring = false;
  }

  //  Check immediately
  static Future<bool> checkNow() async {
    return await SharedPreferencesService.isTokenExpired();
  }
}
