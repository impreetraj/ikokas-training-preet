import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import '../data/database_helper.dart';

class BackupRestoreService {
  static const String dbName = 'transactions.db';

  
  static Future<bool> backupData(BuildContext context, {String filter = 'all'}) async {
    try {
  
      await DatabaseHelper.instance.close();

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, dbName);
      final dbFile = File(path);

      if (!await dbFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No database found to backup!')),
          );
        }
        return false;
      }

    
      final tempDir = await getTemporaryDirectory();
      
      File targetDbFile = dbFile;
      if (filter != 'all') {
        final tempDbPath = join(tempDir.path, 'temp_backup_filter.db');
        targetDbFile = File(tempDbPath);
        if (await targetDbFile.exists()) await targetDbFile.delete();
        await dbFile.copy(tempDbPath);
        
        final tempDb = await openDatabase(tempDbPath);
        if (filter == 'credit') {
          await tempDb.delete('transactions', where: 'type != ?', whereArgs: ['Income']);
        } else if (filter == 'debit') {
          await tempDb.delete('transactions', where: 'type != ?', whereArgs: ['Expense']);
        }
        await tempDb.close();
      }

      final tempZipPath = join(tempDir.path, 'MyExpenseBackup.zip');
      
    
      final bytes = await targetDbFile.readAsBytes();
      
      if (filter != 'all' && await targetDbFile.exists()) {
        await targetDbFile.delete();
      }

      final archive = Archive();
      archive.addFile(ArchiveFile('transactions.db', bytes.length, bytes));
      
      final zipFile = File(tempZipPath);
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes != null) {
        await zipFile.writeAsBytes(zipBytes);
      }

      final xFile = XFile(tempZipPath, mimeType: 'application/zip');
      await Share.shareXFiles([xFile], text: 'My Expense App Data Backup (Please select this ZIP when restoring)');
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
      return false;
    }
  }

  
  static Future<bool> restoreData(BuildContext context, {String? currentUserId}) async {
    try {
      
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'db', 'pdf'],
      );

      if (result.isEmpty) {
        return false; 
      }

      final backupFilePath = result.first.path;
      if (backupFilePath == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid file path!')),
          );
        }
        return false;
      }

      final backupFile = File(backupFilePath);
      if (!await backupFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup file does not exist!')),
          );
        }
        return false;
      }
      
      
      await DatabaseHelper.instance.close();

      
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, dbName);
      final tempRestorePath = join(dbPath, 'temp_restore.db');
      
      if (backupFilePath.toLowerCase().endsWith('.zip')) {
        
        final bytes = await backupFile.readAsBytes();
        final archive = ZipDecoder().decodeBytes(bytes);
        
        bool foundDb = false;
        for (final file in archive) {
          if (file.name == 'transactions.db' || file.name.endsWith('.db')) {
            final dbOut = File(tempRestorePath);
            await dbOut.writeAsBytes(file.content as List<int>);
            foundDb = true;
            break;
          }
        }
        
        if (!foundDb) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid backup file! No database found inside the ZIP.')),
            );
          }
          return false;
        }
      } else {
    
        await backupFile.copy(tempRestorePath);
      }
      
     
      bool isValid = false;
      try {
        final testDb = await openReadOnlyDatabase(tempRestorePath);
        final result = await testDb.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='transactions'");
        await testDb.close();
        isValid = result.isNotEmpty;
      } catch (e) {
        isValid = false;
      }
      
      if (!isValid) {
        final tempFile = File(tempRestorePath);
        if (await tempFile.exists()) await tempFile.delete();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid file! This is not a valid backup file for this app.')),
          );
        }
        return false;
      }
      

      final walFile = File('$path-wal');
      final shmFile = File('$path-shm');
      if (await walFile.exists()) await walFile.delete();
      if (await shmFile.exists()) await shmFile.delete();
      
 
      final tempFile = File(tempRestorePath);
      await tempFile.rename(path);

      if (currentUserId != null) {
        final db = await openDatabase(path);
        await db.update('transactions', {'userId': currentUserId});
        await db.close();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully')),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
      return false;
    }
  }
}
