import 'package:expense_tracker/data.dart';
import 'package:expense_tracker/screens/action.dart';
import 'package:expense_tracker/screens/history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

double total = income + outcome;
double income = 0;
double outcome = 0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals(transactionsData);
    final double totalIncome = totals.income;
    final double totalOutcome = totals.outcome;
    final double total = totalIncome - totalOutcome;

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context, totalIncome, totalOutcome, total),
      bottomNavigationBar: _buildBottomBar(context),
      extendBody: true,
      floatingActionButton: _buildAction(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
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

  // Widget _buildAppBarTitleRight() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     children: [
  //       IconButton(
  //         icon: const Icon(CupertinoIcons.settings),
  //         onPressed: () {},
  //       ),
  //     ],
  //   );
  // }

  Widget _buildBody(
      BuildContext context, double income, double outcome, double total) {
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
                        _buildIncome(income),
                        Expanded(
                          child: _buildOutcome(outcome),
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

  Widget _buildIncome(double income) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: 5,
        ),
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
            const SizedBox(
              width: 40,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutcome(double outcome) {
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
            const SizedBox(
              width: 5,
            ),
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
                  const Text("clicked");
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
              itemCount: transactionsData.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                for (int i = 0; i < transactionsData.length; i++) {
                  double currentAmount =
                      double.parse(transactionsData[i]['totalAmount']);
                  if (currentAmount >= 0) {
                    income += currentAmount;
                  } else {
                    outcome += currentAmount;
                  }
                }
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50.0,
                        height: 55.0,
                        decoration: BoxDecoration(
                          color: transactionsData[index]['color'],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: transactionsData[index]['icon'],
                        ),
                      ),
                      const SizedBox(
                          width: 10.0), // Add spacing between circle and text
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
                                      transactionsData[index]['name'],
                                    ),
                                  ),
                                ],
                              ),
                              //subtitle: Text(transactionsData[index]['date']),
                              trailing: Text(
                                transactionsData[index]['totalAmount'],
                                style: TextStyle(
                                  color: double.parse(transactionsData[index]
                                              ['totalAmount']) >=
                                          0
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 16,
                                ),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => History()),
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

  // Function to calculate income and outcome
  Totals _calculateTotals(List<dynamic> transactionsData) {
    double income = 0.0;
    double outcome = 0.0;

    for (var transaction in transactionsData) {
      final double amount = double.parse(transaction['totalAmount']);
      income += amount >= 0 ? amount : 0;
      outcome += amount < 0 ? amount.abs() : 0;
    }

    return Totals(income: income, outcome: outcome);
  }
}
