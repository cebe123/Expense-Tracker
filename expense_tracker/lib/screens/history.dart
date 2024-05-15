import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/screens/action.dart';
import 'package:expense_tracker/screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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
                  ? Icons.arrow_drop_down
                  : Icons.arrow_drop_up;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(iconData, color: itemColor),
                  title: Text("Amount: ${item['value']}",
                      style: TextStyle(color: itemColor)),
                  subtitle: Text(
                      "Date: ${item['date']}   -   Category: ${item['category']}",
                      style: TextStyle(color: itemColor)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      if (item['key'] != null) {
                        expensesdb.child(item['key']).remove().then((_) {
                          setState(() {
                            newHistoryItems.removeAt(index);
                          });
                        });
                      }
                    },
                  ),
                ),
              );
            },
          );
        }
      },
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
            ],
          ),
        ],
      ),
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
