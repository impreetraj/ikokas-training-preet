import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../services/backup_restore_service.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String deviceName = "Unknown Device";
  IconData deviceIcon = Icons.device_unknown;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDeviceInfo();
  }

  Future<void> _initDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String name;
    IconData icon = Icons.device_unknown;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        name = '${androidInfo.brand} ${androidInfo.model}'.trim();
        icon = Icons.phone_android;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        name = iosInfo.name; 
        icon = Icons.phone_iphone;
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await deviceInfoPlugin.windowsInfo;
        name = 'Windows PC (${windowsInfo.computerName})';
        icon = Icons.computer;
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macInfo = await deviceInfoPlugin.macOsInfo;
        name = 'Mac (${macInfo.computerName})';
        icon = Icons.laptop_mac;
      } else {
        name = '${Platform.operatingSystem[0].toUpperCase()}${Platform.operatingSystem.substring(1)} Device';
        icon = Icons.computer;
      }
      
     
    } catch (e) {
      name = "Unknown Device";
      icon = Icons.device_unknown;
    }

    if (mounted) {
      setState(() {
        deviceName = name;
        deviceIcon = icon;
        isLoading = false;
      });
    }
  }

  void _showBackupOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Backup Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.storage, color: Colors.teal),
                title: const Text('All Data'),
                onTap: () {
                  Navigator.pop(context);
                  BackupRestoreService.backupData(context, filter: 'all');
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.green),
                title: const Text('Only Credit (Income)'),
                onTap: () {
                  Navigator.pop(context);
                  BackupRestoreService.backupData(context, filter: 'credit');
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.red),
                title: const Text('Only Debit (Expense)'),
                onTap: () {
                  Navigator.pop(context);
                  BackupRestoreService.backupData(context, filter: 'debit');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security & Login',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Active Devices',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This account is currently logged in on the following device:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    isLoading 
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(deviceIcon, color: Colors.white),
                          ),
                          title: Text(deviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Current Device • Active now', style: TextStyle(color: Colors.green)),
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Data Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backup & Restore',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Backup your app data or restore from a previously saved backup file.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showBackupOptions(context);
                            },
                            icon: const Icon(Icons.backup),
                            label: const Text('Backup'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final currentUser = ref.read(authProvider);
                              final success = await BackupRestoreService.restoreData(context, currentUserId: currentUser?.uid);
                              if (success && mounted) {
                                ref.invalidate(transactionProvider);
                                ref.invalidate(transactionLogsProvider);
                              }
                            },
                            icon: const Icon(Icons.restore),
                            label: const Text('Restore'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.teal,
                              side: const BorderSide(color: Colors.teal),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
