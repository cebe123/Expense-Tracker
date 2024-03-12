import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(98, 177, 177, 177),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color.fromARGB(210, 189, 189, 198),
                  radius: 20,
                  child: Icon(
                    Icons.person_3_sharp,
                    color: Color.fromRGBO(70, 70, 70, 0.573),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "User name",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(),
    );
  }
}
