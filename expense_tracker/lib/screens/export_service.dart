// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class ExportService {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('expenses');

  Future<void> exportDataToCSV() async {
    try {
      DatabaseEvent event = await _databaseReference.once();
      DataSnapshot snapshot = event.snapshot;
      List<List<dynamic>> rows = [];

      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        // Add headers to the CSV file
        rows.add(['Date', 'Category', 'Amount', 'Description']);

        data.forEach((key, value) {
          rows.add([
            value['date'],
            value['category'],
            value['amount'],
            value['description']
          ]);
        });

        String csv = const ListToCsvConverter().convert(rows);

        final directory = await getApplicationDocumentsDirectory();
        final path = "${directory.path}/expenses.csv";
        final file = File(path);
        await file.writeAsString(csv);
      }
    } catch (e) {
      // Handle any errors that might occur
      print('Error exporting data to CSV: $e');
    }
  }
}
