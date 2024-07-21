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
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  int selectedYear = DateTime.now().year;

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
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
        child: Column(
          children: [
            _buildYearStrip(),
            _buildMonthStrip(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
      extendBody: true,
      floatingActionButton: _buildAction(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildYearStrip() {
    List<int> years = List.generate(10, (index) => DateTime.now().year - index);
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: years.map((year) {
            bool isSelected = year == selectedYear;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedYear = year;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    year.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'SF Pro Text',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMonthStrip() {
    List<String> months = List.generate(12, (index) {
      return DateFormat('MMMM').format(DateTime(0, index + 1));
    });

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: months.map((month) {
            bool isSelected = month == selectedMonth;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedMonth = month;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    month,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'SF Pro Text',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
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

          // Filter items by selected month and year
          newHistoryItems = newHistoryItems.where((item) {
            DateTime date = DateFormat('dd-MM-yyyy').parse(item['date']);
            return DateFormat('MMMM').format(date) == selectedMonth &&
                date.year == selectedYear;
          }).toList();

          // Group items by date
          Map<String, List<Map<dynamic, dynamic>>> groupedItems = {};
          for (var item in newHistoryItems) {
            DateTime date = DateFormat('dd-MM-yyyy').parse(item['date']);
            String formattedDate = DateFormat('dd MMMM').format(date);

            if (groupedItems.containsKey(formattedDate)) {
              groupedItems[formattedDate]!.add(item);
            } else {
              groupedItems[formattedDate] = [item];
            }
          }

          // Sort dates from newest to oldest
          var sortedDates = groupedItems.keys.toList()
            ..sort((a, b) => DateFormat('dd MMMM')
                .parse(b)
                .compareTo(DateFormat('dd MMMM').parse(a)));

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              String date = sortedDates[index];
              List<Map<dynamic, dynamic>> items = groupedItems[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2.0, horizontal: 16.0),
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.withOpacity(0.6),
                        fontFamily: 'Cupertino',
                      ),
                    ),
                  ),
                  ...items.map((item) {
                    bool isIncome = item['category'] == 'Income';
                    Color itemColor = isIncome ? Colors.green : Colors.red;
                    IconData iconData = isIncome
                        ? CupertinoIcons.arrow_up_circle_fill
                        : CupertinoIcons.arrow_down_circle_fill;
                    DateTime itemDate =
                        DateFormat('dd-MM-yyyy').parse(item['date']);
                    String formattedItemDate =
                        DateFormat('dd-MM-yyyy').format(itemDate);

                    return Card(
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: isIncome
                                ? [Colors.green.shade300, Colors.green.shade600]
                                : [Colors.red.shade100, Colors.red.shade300],
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
                            child: Icon(iconData,
                                color: itemColor.withOpacity(0.9)),
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
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Date: $formattedItemDate - Category: ${item['category']}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Roboto',
                                        color: Colors.white70,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black12,
                                            offset: Offset(3, 8),
                                            blurRadius: 1.5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (item['description'] != null &&
                                  item['description'].toString().isNotEmpty)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['description'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w300,
                                          fontFamily: 'Roboto',
                                          color: CupertinoColors.systemGrey,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black12,
                                              offset: Offset(3, 8),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
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
                                icon: const Icon(CupertinoIcons.delete,
                                    color: Colors.white),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            const Text("Delete Confirmation"),
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
                                                    items.remove(item);
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
                  }),
                ],
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
