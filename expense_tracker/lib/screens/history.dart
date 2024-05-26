// ignore_for_file: unused_local_variable

import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/screens/action.dart';
import 'package:expense_tracker/screens/home.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // Listen for refresh signal from other pages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context)?.settings.arguments as bool? ?? false) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(context),
      extendBody: true,
      floatingActionButton: _buildAction(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    return FutureBuilder<DataSnapshot>(
      future: expensesdb.once().then((event) => event.snapshot),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.value == null) {
          return const Center(child: Text('No history items found'));
        } else {
          Map<dynamic, dynamic> data =
              snapshot.data!.value as Map<dynamic, dynamic>;
          var newHistoryItems =
              data.entries.map((e) => {"key": e.key, ...e.value}).toList();
          return ListView.builder(
            itemCount: newHistoryItems.length,
            itemBuilder: (context, index) {
              var item = newHistoryItems[index];
              Color itemColor = item['value'] >= 0 ? Colors.green : Colors.red;
              IconData iconData = item['value'] >= 0
                  ? CupertinoIcons.arrow_up_circle_fill
                  : CupertinoIcons.arrow_down_circle_fill;
              DateTime date = DateFormat('dd-MM-yyyy').parse(item['date']);

              String formattedDate = DateFormat('dd-MM-yyyy').format(date);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    gradient: LinearGradient(
                      colors: item['value'] >= 0
                          ? [Colors.green.shade300, Colors.green.shade600]
                          : [Colors.red.shade300, Colors.red.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(iconData, color: itemColor.withOpacity(0.9)),
                    ),
                    title: Text(
                      "Amount: ₺${item['value']}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Roboto',
                        color: CupertinoColors.darkBackgroundGray,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(3, 8),
                            blurRadius: 1.5,
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      "Date: $formattedDate   -   Category: ${item['category']}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Roboto',
                        color: CupertinoColors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(3, 8),
                            blurRadius: 1.5,
                          ),
                        ],
                      ),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.black26,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Delete Confirmation"),
                                  content: const Text(
                                      "Are you sure you want to delete this item?"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("Delete"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        if (item['key'] != null) {
                                          expensesdb
                                              .child(item['key'])
                                              .remove()
                                              .then((_) {
                                            setState(() {
                                              newHistoryItems.removeAt(index);
                                            });
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildBottomBar(context) {
    int currentIndex = 1;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(30),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 3,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.graph_circle_fill), label: "History"),
        ],
        onTap: (index) {
          // Handle navigation based on tapped index
          if (index == 0) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.pop(context, true); // Signal for refresh
          }
        },
      ),
    );
  }

  Widget _buildAction() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ActionPage()),
        );
      },
      shape: const CircleBorder(),
      child: const Icon(CupertinoIcons.add),
    );
  }
}
