import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _autoSaveEnabled = false;
  bool _autoSaveBackupEnabled = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = context.read<SettingsProvider>();
    if (!settings.isInitialized) {
      await settings.init();
    }
    setState(() {
      _autoSaveEnabled = settings.isAutoSaveEnabled;
      _autoSaveBackupEnabled = settings.isAutoSaveBackupEnabled;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading settings...'),
            ],
          ),
        ),
      );
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              // Auto Save Settings
              const Text(
                'Auto Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Enable Auto Save'),
                subtitle: const Text('Automatically save changes after 2 seconds of inactivity'),
                value: _autoSaveEnabled,
                onChanged: (value) {
                  setState(() => _autoSaveEnabled = value);
                  context.read<SettingsProvider>().setAutoSaveEnabled(value);
                },
              ),
              if (_autoSaveEnabled)
                SwitchListTile(
                  title: const Text('Create Backup Before Auto Save'),
                  subtitle: const Text('Create a backup copy before auto-saving'),
                  value: _autoSaveBackupEnabled,
                  onChanged: (value) {
                    setState(() => _autoSaveBackupEnabled = value);
                    context.read<SettingsProvider>().setAutoSaveBackupEnabled(value);
                  },
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
