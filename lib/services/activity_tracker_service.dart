import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityTrackerService {
  static Timer? _inactivityTimer;
  static DateTime? _lastActivityTime;
  static bool _isTracking = false;

  // Inactivity timeout: 1 JAM (idle logout)
  static const Duration inactivityTimeout = Duration(hours: 1);

  // Notifier untuk inactivity logout
  static ValueNotifier<bool> inactivityLogoutNotifier = ValueNotifier<bool>(
    false,
  );

  //  Start tracking user activity
  static void startTracking() {
    if (_isTracking) {
      return;
    }

    _isTracking = true;
    _lastActivityTime = DateTime.now();

    // Save initial activity time
    _saveLastActivityTime();

    // Start inactivity timer
    _resetInactivityTimer();
  }

  // Stop tracking
  static void stopTracking() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _isTracking = false;
    _lastActivityTime = null;
  }

  // Reset tracking (on login/logout)
  static void resetTracking() {
    stopTracking();
    inactivityLogoutNotifier.value = false;
  }

  // Record user activity (call this on ANY user interaction)
  static void recordActivity() {
    if (!_isTracking) return;

    _lastActivityTime = DateTime.now();
    _saveLastActivityTime();

    // Reset inactivity timer
    _resetInactivityTimer();

    final now = DateTime.now();
    print(
      '✋ [ACTIVITY_TRACKER] Activity at ${now.hour}:${now.minute}:${now.second}',
    );
  }

  // ✅ Reset inactivity timer
  static void _resetInactivityTimer() {
    _inactivityTimer?.cancel();

    _inactivityTimer = Timer(inactivityTimeout, () {
      print(
        '❌ [ACTIVITY_TRACKER] User inactive for ${inactivityTimeout.inMinutes} minutes!',
      );
      print('❌ [ACTIVITY_TRACKER] Triggering inactivity logout...');

      // Trigger logout
      inactivityLogoutNotifier.value = true;
      stopTracking();
    });
  }

  // ✅ Save last activity time to SharedPreferences
  static Future<void> _saveLastActivityTime() async {
    if (_lastActivityTime != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'last_activity_time',
        _lastActivityTime!.toIso8601String(),
      );
    }
  }

  // ✅ Check if user was inactive (when app resumes from background)
  static Future<bool> checkInactivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivityString = prefs.getString('last_activity_time');

      if (lastActivityString == null) {
        print('⚠️ [ACTIVITY_TRACKER] No last activity time found');
        return false; // No data, consider as active
      }

      final lastActivity = DateTime.parse(lastActivityString);
      final now = DateTime.now();
      final inactiveDuration = now.difference(lastActivity);

      print(
        '📊 [ACTIVITY_TRACKER] Last activity: ${lastActivity.toIso8601String()}',
      );
      print(
        '📊 [ACTIVITY_TRACKER] Inactive for: ${inactiveDuration.inMinutes} minutes',
      );

      if (inactiveDuration > inactivityTimeout) {
        print('❌ [ACTIVITY_TRACKER] User was inactive for too long!');
        return true; // Inactive too long
      }

      print('✅ [ACTIVITY_TRACKER] User activity within timeout');
      return false; // Still active
    } catch (e) {
      print('💥 [ACTIVITY_TRACKER] Error checking inactivity: $e');
      return false;
    }
  }

  // Get time until inactivity logout
  static Duration? getTimeUntilInactivity() {
    if (_lastActivityTime == null) return null;

    final now = DateTime.now();
    final elapsed = now.difference(_lastActivityTime!);
    final remaining = inactivityTimeout - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }
}
