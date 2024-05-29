// ignore_for_file: prefer_final_fields, unused_field, unused_local_variable, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'dart:convert'; // Import dart:convert for UTF-8 encoding
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';

class SettingsPage extends StatefulWidget {
  final List<Map<String, dynamic>> fetchedData;

  const SettingsPage({super.key, required this.fetchedData});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              color: CupertinoColors.activeBlue,
              onPressed: () async {
                await requestPermissions(context);

                if (widget.fetchedData.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No data to export')),
                  );
                  return;
                }

                String? csvData = convertToCSV(context, widget.fetchedData);

                if (csvData != null) {
                  await saveCSVToFile(context, csvData);
                }
              },
              child: const Text('Export to CSV'),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              color: CupertinoColors.destructiveRed,
              onPressed: () {
                _showResetConfirmationDialog(context);
              },
              child: const Text('Reset All Data'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> requestPermissions(BuildContext context) async {
    if (await Permission.storage.request().isGranted) {
      print('Storage permission granted');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission granted')),
      );
    } else {
      if (await Permission.manageExternalStorage.request().isGranted) {
        print('Manage External Storage permission granted');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Manage External Storage permission granted')),
        );
      } else {
        print('Manage External Storage permission denied');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Manage External Storage permission denied')),
        );
      }
    }
  }

  String? convertToCSV(BuildContext context, List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      print('No data to convert to CSV');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to convert to CSV')),
      );
      return null;
    }

    List<List<dynamic>> rows = [];
    List<dynamic> headers = data[0].keys.toList();
    rows.add(headers);

    for (var map in data) {
      List<dynamic> row = [];
      for (var value in map.values) {
        row.add(value);
      }
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);
    print('Data converted to CSV');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data converted to CSV')),
    );

    return csv;
  }

  Future<void> saveCSVToFile(BuildContext context, String csvData) async {
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      Directory? downloadsDirectory = await getExternalStorageDirectory();
      String downloadsPath =
          '/storage/emulated/0/Download'; // Set to Downloads directory

      File file = File('$downloadsPath/expenses.csv');
      await file.writeAsString(csvData,
          encoding: utf8); // Ensure correct encoding

      print('CSV file saved to $downloadsPath/expenses.csv');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('CSV file saved to $downloadsPath/expenses.csv')),
      );
    } else {
      print('Storage permission not granted');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission not granted')),
      );
    }
  }

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Reset All Data'),
          content: const Text('Are you sure you want to delete all data?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Confirm'),
              onPressed: () async {
                await _resetAllData(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetAllData(BuildContext context) async {
    print('Resetting all data...');
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child('expenses');
    await databaseReference.remove();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data reset successfully')),
    );
  }
}
