import 'package:flutter/material.dart';

import 'homePage/homepage.dart';

void main() {
  runApp(const UserInfo());
}

class UserInfo extends StatelessWidget {
  const UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AddPerson(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AddPerson extends StatefulWidget {
  const AddPerson({super.key});

  @override
  State<AddPerson> createState() => _AddPersonState();
}

class _AddPersonState extends State<AddPerson> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Information'),
        ),
        body: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15),
                  height: 100,
                  child: const Text(
                    'It looks like you don’t have account in this '
                    'number. Please let us know some information for '
                    'a secure service.',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 170,
                  width: MediaQuery.of(context).size.width * 1,
                  padding: const EdgeInsets.all(5.0),
                  child: ListView(
                    children: [
                      const SizedBox(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                Material(
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(12),
                    // width: MediaQuery.of(context).size.width * 1,
                    color: Colors.blue,
                    child: TextField(
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.account_circle_outlined,
                          size: 30,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                  ),
                ),
                Material(
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(12),
                    // width: MediaQuery.of(context).size.width * 1,
                    color: Colors.blue,
                    child: TextField(
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                        labelText: 'Full Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          size: 30,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 35,
                  width: MediaQuery.of(context).size.width *
                      0.9, // Width set to 90% of screen width
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint("ok");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
