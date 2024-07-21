// ignore_for_file: unused_local_variable

import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/screens/action.dart';
import 'package:expense_tracker/screens/history.dart';
import 'package:expense_tracker/screens/settings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

double income = 0;
double outcome = 0;
double total = 0;
List<dynamic> fetchedData = [];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      calculate();
      setState(() {
        calculate();
      });
    });
  }

  Future<void> _fetchData() async {
    try {
      // Listening to changes in the database
      expensesdb.ref.onValue.listen((event) {
        if (event.snapshot.value != null) {
          var data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
          fetchedData = data.values.toList();

          setState(() {
            // calculate after fetching data
            calculate();
          });
        } else {
          // Handle the case when no data is available
          setState(() {
            fetchedData = [];
          });
        }
      });
    } catch (e) {
      // Handle any errors that occur during data fetching
      Text("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(30.0), // Set the height of the AppBar
        child: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              iconSize: 24,
              onPressed: () {
                // Convert fetchedData to List<Map<String, dynamic>> before passing
                List<Map<String, dynamic>> data = fetchedData
                    .map((item) => Map<String, dynamic>.from(item))
                    .toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(fetchedData: data),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomBar(context),
      extendBody: true,
      floatingActionButton: _buildAction(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Map<String, double> calculate() {
    double totalIncome = 0;
    double totalOutcome = 0;

    for (int i = 0; i < fetchedData.length; i++) {
      double currentAmount = double.parse(fetchedData[i]['value'].toString());
      String category = fetchedData[i]['category'];

      if (category == 'Income') {
        totalIncome += currentAmount;
      } else {
        totalOutcome += currentAmount;
      }
    }
    total = totalIncome - totalOutcome; // Total balance calculation

    return {
      'income': totalIncome,
      'outcome': totalOutcome,
      'total': total,
    };
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 15),
          Center(
            child: Container(
              // Gradient Box
              height: 200,
              width: 300,
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color.fromRGBO(82, 78, 199, 0.937),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    spreadRadius: 0.5,
                    offset: Offset(5, 5),
                  )
                ],
                gradient: const LinearGradient(
                  transform: GradientRotation(30),
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.purple, Colors.blue],
                ),
              ),
              child: Column(
                children: <Widget>[
                  _buildBalance(context, total),
                  const SizedBox(
                    height: 50,
                    width: 10,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          _buildIncome(),
                          Expanded(
                            child: _buildOutcome(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          _buildTransactions(context),
        ],
      ),
    );
  }

  Widget _buildBalance(BuildContext context, double total) {
    Map<String, double> incomeData = calculate();
    total = incomeData['total']!;
    return Column(
      children: [
        const Column(
          children: [
            SizedBox(height: 10),
            Text(
              "Total Balance",
              textAlign: TextAlign.center,
              style: TextStyle(
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
          ],
        ),
        Column(
          children: [
            const SizedBox(height: 5),
            Text(
              total.toStringAsFixed(2),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                fontFamily: 'Roboto',
                color: CupertinoColors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(3, 8),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncome() {
    Map<String, double> incomeData = calculate();
    income = incomeData['income']!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 5),
        Row(
          children: [
            const Icon(
              CupertinoIcons.arrow_down_circle_fill,
              color: Color.fromRGBO(183, 183, 183, 0.5),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Income",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w200,
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
                Text(
                  "₺${income.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                    color: Colors.green, // Changed to green
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(3, 8),
                        blurRadius: 1.5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 40),
          ],
        ),
      ],
    );
  }

  Widget _buildOutcome() {
    Map<String, double> incomeData = calculate();
    outcome = incomeData['outcome']!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(
              CupertinoIcons.arrow_up_circle_fill,
              color: Color.fromRGBO(183, 183, 183, 0.5),
            ),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Outcome",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w200,
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
                Text(
                  "₺${outcome.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                    color: Colors.red, // Changed to red
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(3, 8),
                        blurRadius: 1.5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactions(BuildContext context) {
    Map<String, IconData> categoryIcons = {
      'Income': CupertinoIcons.money_dollar,
      'Food': Icons.fastfood,
      'Transportation': Icons.directions_car,
      'Shopping': Icons.shopping_cart,
      'Health': Icons.health_and_safety,
      'Travel': Icons.card_travel,
      'Insurance': Icons.accessibility,
      'Credit': Icons.credit_card,
      'Other': Icons.error,
    };

    // Check if fetchedData is loaded
    if (fetchedData.isEmpty) {
      return const Center(
        child: Center(
          child: Text("Not Found !"),
        ),
      );
    }

    Map<String, double> categoryTotals = {};
    for (var expense in fetchedData) {
      String category = expense['category'];
      double amount = double.parse(expense['value'].toString());

      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = categoryTotals[category]! + amount;
      } else {
        categoryTotals[category] = amount;
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Transactions",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: CupertinoColors.systemGrey2,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryPage()),
                  );
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(0, 0, 0, 0.50),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categoryTotals.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                DateTime date =
                    DateFormat('dd-MM-yyyy').parse(fetchedData[index]['date']);
                String formattedDate = DateFormat('dd MM yyyy').format(date);

                String category = categoryTotals.keys.elementAt(index);
                double totalAmount = categoryTotals[category]!;
                Color itemColor =
                    category == 'Income' ? Colors.green : Colors.red;
                IconData itemIcon = categoryIcons[category] ?? Icons.category;

                return GestureDetector(
                  onTap: () {
                    _showCategoryDetails(category);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: category == 'Income'
                              ? [Colors.green.shade200, Colors.green.shade400]
                              : [
                                  const Color(0xFFFDE1E1),
                                  const Color(0xFFF8C3C3)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: category == 'Income'
                                  ? [
                                      Colors.green.shade300,
                                      Colors.green.shade600
                                    ]
                                  : [Colors.red.shade300, Colors.red.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: category == 'Income'
                                    ? Colors.green.withOpacity(0.9)
                                    : Colors.red.withOpacity(0.9),
                                blurRadius: 8,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(itemIcon, color: Colors.white),
                          ),
                        ),
                        title: Text(
                          category,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(2, 5),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        subtitle: Text(
                          "Last Operation :\n $formattedDate",
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 14),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₺${totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: CupertinoColors.darkBackgroundGray,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 5),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDetails(String category) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
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
              var newHistoryItems = data.entries
                  .where((e) => e.value['category'] == category)
                  .map((e) => {"key": e.key, ...e.value})
                  .toList();
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return ListView.builder(
                    itemCount: newHistoryItems.length,
                    itemBuilder: (context, index) {
                      var item = newHistoryItems[index];
                      Color itemColor = item['category'] == 'Income'
                          ? Colors.green
                          : Colors.red;
                      IconData iconData = item['category'] == 'Income'
                          ? CupertinoIcons.money_dollar
                          : CupertinoIcons.arrow_down_circle_fill;
                      DateTime date =
                          DateFormat('dd-MM-yyyy').parse(item['date']);
                      String formattedDate =
                          DateFormat('dd-MM-yyyy').format(date);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            gradient: LinearGradient(
                              colors: item['category'] == 'Income'
                                  ? [
                                      Colors.green.shade300,
                                      Colors.green.shade600
                                    ]
                                  : [
                                      const Color(0xFFFDE1E1),
                                      const Color(0xFFF8C3C3)
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(
                                  colors: item['category'] == 'Income'
                                      ? [
                                          Colors.green.shade300,
                                          Colors.green.shade600
                                        ]
                                      : [
                                          const Color(0xFFF7A1A1),
                                          const Color(0xFFF76E6E)
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: item['category'] == 'Income'
                                        ? Colors.green.withOpacity(0.5)
                                        : Colors.red.withOpacity(0.5),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(iconData, color: Colors.white),
                              ),
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
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date: $formattedDate   -   Category: ${item['category']}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Roboto',
                                    color: Colors.black87,
                                  ),
                                ),
                                if (item['description'] != null &&
                                    item['description'].toString().isNotEmpty)
                                  Text(
                                    item['description'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Roboto',
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.black26,
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
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
                                                    setModalState(() {
                                                      newHistoryItems
                                                          .removeAt(index);
                                                    });
                                                    setState(() {
                                                      fetchedData.removeWhere(
                                                          (element) =>
                                                              element['key'] ==
                                                              item['key']);
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
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildBottomBar(context) {
    int currentIndex = 0;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(30),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.grey.shade200, // Light metallic grey background
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 3,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home, color: Colors.grey.shade700),
            activeIcon: Icon(CupertinoIcons.home, color: Colors.grey.shade900),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.graph_circle_fill,
                color: Colors.grey.shade700),
            activeIcon: Icon(CupertinoIcons.graph_circle_fill,
                color: Colors.grey.shade900),
            label: "History",
          ),
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
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildAction() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => const ActionPage(),
        ));
      },
      shape: const CircleBorder(),
      child: const Icon(CupertinoIcons.add),
    );
  }
}
