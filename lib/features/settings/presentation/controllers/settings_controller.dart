import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController(ref);
});

class SettingsState {
  final bool notificationsEnabled;
  final int reminderMinutes;
  final DateTime? lastSyncTime;
  final bool autoSync;

  SettingsState({
    this.notificationsEnabled = true,
    this.reminderMinutes = 15,
    this.lastSyncTime,
    this.autoSync = true,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    int? reminderMinutes,
    DateTime? lastSyncTime,
    bool? autoSync,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      autoSync: autoSync ?? this.autoSync,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  static const _keyNotifications = 'notifications_enabled';
  static const _keyReminderMinutes = 'reminder_minutes';
  static const _keyLastSync = 'last_sync_time';
  static const _keyAutoSync = 'auto_sync';

  SettingsController(Ref _ref) : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
      final reminderMinutes = prefs.getInt(_keyReminderMinutes) ?? 15;
      final lastSyncTimeMillis = prefs.getInt(_keyLastSync);
      final autoSync = prefs.getBool(_keyAutoSync) ?? true;

      state = SettingsState(
        notificationsEnabled: notificationsEnabled,
        reminderMinutes: reminderMinutes,
        lastSyncTime: lastSyncTimeMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(lastSyncTimeMillis)
            : null,
        autoSync: autoSync,
      );
    } catch (e) {
      // Use default settings if loading fails
      state = SettingsState();
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNotifications, enabled);
    } catch (e) {
      // Ignore persistence errors
    }
  }

  Future<void> setReminderMinutes(int minutes) async {
    state = state.copyWith(reminderMinutes: minutes);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyReminderMinutes, minutes);
    } catch (e) {
      // Ignore persistence errors
    }
  }

  Future<void> syncNow() async {
    state = state.copyWith(lastSyncTime: DateTime.now());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLastSync, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Ignore persistence errors
    }
  }

  Future<void> setAutoSync(bool enabled) async {
    state = state.copyWith(autoSync: enabled);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAutoSync, enabled);
    } catch (e) {
      // Ignore persistence errors
    }
  }
}
