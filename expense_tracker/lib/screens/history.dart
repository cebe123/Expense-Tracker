import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/screens/action.dart';
import 'package:expense_tracker/screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<StatefulWidget> createState() {
    return HistoryPage();
  }
}

class HistoryPage extends State<History> {
  final databaseReference = FirebaseDatabase.instance;
  List<Map<String, dynamic>> historyItems = []; // List to store retrieved data

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch data from database on page load
  }

  Future<void> _fetchData() async {
    try {
      DatabaseEvent event = await expensesdb.once();
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> data =
            Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        historyItems.clear(); // Clear existing data before adding new items

        data.forEach(
          (key, value) {
            if (value is Map) {
              historyItems.add(
                {
                  'id': key,
                  'value': value['value'],
                  'date': value['date'],
                },
              );
            }
          },
        );
      }
      setState(() {}); // Update UI to reflect changes
    } catch (error) {
      print('Error fetching data: $error');
      // Handle potential errors (e.g., display error message)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
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

  Widget _buildBody() {
    return historyItems.isNotEmpty
        ? ListView.builder(
            itemCount: historyItems.length,
            itemBuilder: (context, index) {
              var item = historyItems[index];
              return ListTile(
                //title: Text("Expense ID: ${item['id']}"),
                title: Text("Amount: ${item['value']}"),
                subtitle: Text(
                    "Date: ${context.watch<DateProvider>().selectedDate ?? ''}"),
              );
            })
        : const Center(child: Text('No history items found'));
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const History()),
            );
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
