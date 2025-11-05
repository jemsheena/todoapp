import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_controller.dart';
import '../../../../app/theme/theme_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _loadAppVersion();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (e) {
      // Use default version if loading fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final settingsController = ref.read(settingsProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);
    final themeController = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeTransition(
            opacity: _animationController,
            child: _buildAppearanceSection(context, themeMode, themeController),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _animationController,
            child: _buildDataSyncSection(context, settingsState, settingsController),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _animationController,
            child: _buildNotificationsSection(
              context,
              settingsState,
              settingsController,
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _animationController,
            child: _buildAboutSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    ThemeMode themeMode,
    ThemeModeController controller,
  ) {
    String themeModeText;
    IconData themeIcon;
    switch (themeMode) {
      case ThemeMode.light:
        themeModeText = 'Light';
        themeIcon = Icons.light_mode;
        break;
      case ThemeMode.dark:
        themeModeText = 'Dark';
        themeIcon = Icons.dark_mode;
        break;
      case ThemeMode.system:
        themeModeText = 'System default';
        themeIcon = Icons.brightness_auto;
        break;
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(themeIcon),
            title: const Text('Theme'),
            subtitle: Text(themeModeText),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              HapticFeedback.selectionClick();
              _showThemePicker(context, controller, themeMode);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataSyncSection(
    BuildContext context,
    SettingsState settingsState,
    SettingsController controller,
  ) {
    final lastSync = settingsState.lastSyncTime;
    String syncStatusText;
    if (lastSync == null) {
      syncStatusText = 'Never';
    } else {
      final now = DateTime.now();
      final difference = now.difference(lastSync);
      if (difference.inMinutes < 1) {
        syncStatusText = 'Just now';
      } else if (difference.inHours < 1) {
        syncStatusText = '${difference.inMinutes} minutes ago';
      } else if (difference.inDays < 1) {
        syncStatusText = '${difference.inHours} hours ago';
      } else {
        syncStatusText = '${difference.inDays} days ago';
      }
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Data & Sync',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cloud_sync),
            title: const Text('Sync Status'),
            subtitle: Text('Last synced: $syncStatusText'),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                HapticFeedback.mediumImpact();
                controller.syncNow();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Syncing...'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Export or import your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              HapticFeedback.selectionClick();
              _showBackupDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(
    BuildContext context,
    SettingsState settingsState,
    SettingsController controller,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Enable Notifications'),
            trailing: Switch(
              value: settingsState.notificationsEnabled,
              onChanged: (value) {
                HapticFeedback.mediumImpact();
                controller.setNotificationsEnabled(value);
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Remind me'),
            subtitle: Text('${settingsState.reminderMinutes} minutes before due date'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              HapticFeedback.selectionClick();
              _showReminderPicker(context, settingsState, controller);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: Text(_appVersion),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              HapticFeedback.selectionClick();
              _showPrivacyPolicy(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              HapticFeedback.selectionClick();
              _showTermsOfService(context);
            },
          ),
        ],
      ),
    );
  }

  void _showThemePicker(
    BuildContext context,
    ThemeModeController controller,
    ThemeMode currentMode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              subtitle: const Text('Always use light theme'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  HapticFeedback.selectionClick();
                  controller.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              subtitle: const Text('Always use dark theme'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  HapticFeedback.selectionClick();
                  controller.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              subtitle: const Text('Follow system theme'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  HapticFeedback.selectionClick();
                  controller.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderPicker(
    BuildContext context,
    SettingsState settingsState,
    SettingsController controller,
  ) {
    final options = [5, 10, 15, 30, 60];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Reminder Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((minutes) {
            return RadioListTile<int>(
              title: Text('$minutes minutes before'),
              value: minutes,
              groupValue: settingsState.reminderMinutes,
              onChanged: (value) {
                if (value != null) {
                  HapticFeedback.selectionClick();
                  controller.setReminderMinutes(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Backup & Restore'),
        content: const Text(
          'Backup and restore functionality will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Our Privacy Policy explains how we collect, use, and protect your personal information when you use our app. We are committed to protecting your privacy and ensuring the security of your data.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'By using this app, you agree to our Terms of Service. Please read these terms carefully before using the app.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}


