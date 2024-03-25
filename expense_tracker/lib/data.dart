import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

List<Map<String, dynamic>> transactionsData = [
  {
    'icon': const FaIcon(FontAwesomeIcons.burger, color: Colors.grey),
    'color': Colors.yellow,
    'name': 'Food',
    'totalAmount': '-50.00',
    'date': 'Today',
  },
  {
    'icon': const FaIcon(FontAwesomeIcons.bagShopping, color: Colors.grey),
    'color': Colors.purple,
    'name': 'Shopping',
    'totalAmount': '-200.00',
    'date': 'Today',
  },
  {
    'icon': const FaIcon(FontAwesomeIcons.heartCircleCheck, color: Colors.grey),
    'color': Colors.green,
    'name': 'Health',
    'totalAmount': '-50.00',
    'date': 'Yesterday',
  },
  {
    'icon': const FaIcon(FontAwesomeIcons.plane, color: Colors.grey),
    'color': Colors.blue,
    'name': 'Travel',
    'totalAmount': '-100.00',
    'date': 'Yesterday',
  },
  {
    'icon': const FaIcon(FontAwesomeIcons.moneyBill, color: Colors.grey),
    'color': Colors.blue,
    'name': 'Salary',
    'totalAmount': '100.00',
    'date': 'Yesterday',
  },
  {
    'icon':
        const FaIcon(FontAwesomeIcons.moneyBillTransfer, color: Colors.grey),
    'color': Colors.blue,
    'name': 'Income',
    'totalAmount': '500.00',
    'date': 'Yesterday',
  }
];
