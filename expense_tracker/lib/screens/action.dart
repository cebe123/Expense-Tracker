import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/screens/history.dart';
import 'package:expense_tracker/screens/home.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActionPage extends StatefulWidget {
  const ActionPage({super.key});

  @override
  State<ActionPage> createState() => _Action();
}

class _Action extends State<ActionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(context),
      extendBody: true,
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
    final TextEditingController controller = TextEditingController();
    //final expensesRef = FirebaseDatabase.instance.ref().child('expenses');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(hintText: "Enter the value"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    final String value = controller.text.trim();
                    int? integerValue = int.tryParse(value);
                    if (value.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter the value')),
                      );
                      return;
                    }

                    if (integerValue == null) {
                      ErrorHint("Value is not a number");
                      return;
                    }

                    final String expenseId =
                        expensesdb.push().key!; // Generate unique ID
                    await expensesdb.child(expenseId).set(integerValue);

                    controller.clear();
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Expense added successfully!')),
                    );
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(30),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 3,
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
}
