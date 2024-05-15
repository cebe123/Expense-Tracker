// ignore_for_file: avoid_print
import 'dart:math';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/screens/action.dart';
import 'package:expense_tracker/screens/history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      expensesdb.ref.onValue.listen((event) {
        if (event.snapshot.value != null) {
          var data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
          fetchedData = data.values.toList();
          setState(() {
            // calculate after fetching data
            calculate();
          });
        } else {
          const Center(
            child: Text("$e"),
          );
        }
      });
    } catch (e) {
      Center(
        child: Text("An error occured: $e"),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
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
      if (currentAmount >= 0) {
        totalIncome += currentAmount;
      } else {
        totalOutcome += currentAmount;
      }
    }
    total = totalIncome + totalOutcome;

    return {'income': totalIncome, 'outcome': totalOutcome, 'total': total};
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[200],
      toolbarHeight: 60,
      title: _buildAppBarTitle(),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAppBarTitleLeft(),
        //_buildAppBarTitleRight(),
      ],
    );
  }

  Widget _buildAppBarTitleLeft() {
    return SafeArea(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 20.0,
            child: Icon(
              Icons.person_3_sharp,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 13.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[800],
                ),
              ),
              // const Text(
              //   'Username', // Replace with dynamic username
              //   style: TextStyle(
              //     fontSize: 16.0,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Center(
          child: Container(
            //Gradient Box
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
          ],
        ),
      ],
    );
  }

  Widget _buildTransactions(BuildContext context) {
    // Kategorilere göre simgelerin eşleştirildiği bir harita oluştur
    Map<String, IconData> categoryIcons = {
      'Food': Icons.fastfood,
      'Transportation': Icons.directions_car,
      'Shopping': Icons.shopping_cart,
      'Health': Icons.health_and_safety,
      'Travel': Icons.card_travel,
      'Insurance': Icons.accessibility,
      'Credit': Icons.credit_card,
      'Other': Icons.error,
    };

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
                  // Handle view all action
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
            height: 350,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: fetchedData.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                double currentAmount =
                    double.parse(fetchedData[index]['value'].toString());
                Color itemColor =
                    currentAmount >= 0 ? Colors.green : Colors.red;
                IconData itemIcon = categoryIcons[fetchedData[index]
                        ['category']] ??
                    Icons
                        .category; // Eğer kategoriye uygun bir simge yoksa varsayılan bir simge kullan

                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50.0,
                        height: 55.0,
                        decoration: BoxDecoration(
                          color: itemColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(itemIcon),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                              vertical: double.minPositive),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      fetchedData[index]['category'].toString(),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(fetchedData[index]['date']),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    fetchedData[index]['value'].toString(),
                                    style: TextStyle(
                                      color: itemColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    "Category Total: ₺${fetchedData[index]['categoryTotal'].toString()}",
                                    style: TextStyle(
                                      color: itemColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(context) {
    int currentIndex = 0;
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
