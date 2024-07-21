// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'dart:convert';
import 'package:expense_tracker/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  final List<Map<String, dynamic>> fetchedData;

  const SettingsPage({super.key, required this.fetchedData});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
                await requestPermissions();

                if (widget.fetchedData.isEmpty) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No data to export')),
                  );
                  return;
                }

                String? textData = convertToText(widget.fetchedData);

                if (textData != null) {
                  await saveTextToFile(textData);
                }
              },
              child: const Text('Export to CSV'),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              color: CupertinoColors.destructiveRed,
              onPressed: () {
                _showResetConfirmationDialog();
              },
              child: const Text('Reset All Data'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      debugPrint('Storage permission granted');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission granted')),
      );
    } else {
      if (await Permission.manageExternalStorage.request().isGranted) {
        debugPrint('Manage External Storage permission granted');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Manage External Storage permission granted')),
        );
      } else {
        debugPrint('Manage External Storage permission denied');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Manage External Storage permission denied')),
        );
      }
    }
  }

  String? convertToText(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      debugPrint('No data to convert to text');
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to convert to text')),
      );
      return null;
    }

    List<String> rows = [];
    List<String> headers = data[0].keys.map((key) => key.toString()).toList();
    rows.add(headers.join(','));

    for (var map in data) {
      List<String> row = [];
      for (var value in map.values) {
        row.add(value.toString());
      }
      rows.add(row.join(','));
    }

    String text = rows.join('\n');
    debugPrint('Data converted to text');
    if (!mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data converted to text')),
    );

    return text;
  }

  Future<void> saveTextToFile(String textData) async {
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      String downloadsPath =
          '/storage/emulated/0/Download'; // Set to Downloads directory

      File file = File('$downloadsPath/expenses.txt');
      await file.writeAsString(textData,
          encoding: utf8); // Ensure correct encoding

      debugPrint('Text file saved to $downloadsPath/expenses.txt');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Text file saved to $downloadsPath/expenses.txt')),
      );

      await convertTextToCSV(downloadsPath);
    } else {
      debugPrint('Storage permission not granted');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission not granted')),
      );
    }
  }

  Future<void> convertTextToCSV(String path) async {
    String textFilePath = '$path/expenses.txt';
    String csvFilePath = '$path/expenses.csv';

    try {
      final textFile = File(textFilePath);
      final csvFile = File(csvFilePath);

      List<List<dynamic>> csvData = const CsvToListConverter()
          .convert(await textFile.readAsString(encoding: utf8));
      String csv = const ListToCsvConverter().convert(csvData);

      await csvFile.writeAsString(csv, encoding: utf8);

      debugPrint('CSV file saved to $csvFilePath');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV file saved to $csvFilePath')),
      );
    } catch (e) {
      debugPrint('Error converting text file to CSV: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error converting text file to CSV: $e')),
      );
    }
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Reset All Data'),
          content: const Text(
              'Are you sure you want to export and delete all data?'),
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
                Navigator.of(context).pop();
                await _exportAndResetData();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportAndResetData() async {
    if (widget.fetchedData.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export and delete')),
      );
      return;
    }

    // Export data to text and then convert to CSV
    String? textData = convertToText(widget.fetchedData);
    if (textData != null) {
      await saveTextToFile(textData);
    }

    // Delete all data from Firebase
    debugPrint('Resetting all data...');
    expensesdb.remove();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data reset successfully')),
    );
  }
}
