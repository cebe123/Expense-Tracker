import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
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
        _buildAppBarTitleRight(),
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
              const Text(
                'Username', // Replace with dynamic username
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitleRight() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(CupertinoIcons.settings),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
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
                _buildBalance(),
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
        _buildTransactions(),
      ],
    );
  }

  Widget _buildBalance() {
    return const Column(
      children: [
        Column(
          children: [
            SizedBox(
              height: 10,
            ),
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
            SizedBox(
              height: 5,
            ),
            Text(
              "Income-Outcome=",
              textAlign: TextAlign.center,
              style: TextStyle(
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
            )
          ],
        ),
      ],
    );
  }

  Widget _buildIncome() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 15,
        ),
        Row(
          children: [
            Icon(
              CupertinoIcons.arrow_down_circle_fill,
              color: Color.fromRGBO(183, 183, 183, 0.5),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
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
                  "₺1000",
                  style: TextStyle(
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

  Widget _buildOutcome() {
    return const Row(
      children: [
        SizedBox(
          width: 75,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              CupertinoIcons.arrow_down_circle_fill,
              color: Color.fromRGBO(183, 183, 183, 0.5),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
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
                  "₺1000",
                  style: TextStyle(
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

  Widget _buildTransactions() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
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
              // Add action here
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
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(CupertinoIcons.home),
            onPressed: () {
              // Handle Home button press
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.search),
            onPressed: () {
              // Handle Search button press
            },
          ),
          IconButton(
            iconSize: 35,
            icon: const Icon(CupertinoIcons.add_circled),
            onPressed: () {
              // Handle Add button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Handle Notifications button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle Settings button press
            },
          ),
        ],
      ),
    );
  }
}

class Transaction {
  final String title;

  Transaction(this.title);
}

List<Transaction> transactions = [
  Transaction("Food"),
  Transaction("Rent"),
  Transaction("Food"),
  Transaction("Rent"),
  Transaction("Food"),
  Transaction("Rent"),
  Transaction("Food"),
  Transaction("Rent"),
  Transaction("Food"),
  Transaction("Rent"),
  Transaction("Food"),
  Transaction("Rent"),
  Transaction("Food"),
  Transaction("Rent"),
];
