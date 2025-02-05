import 'package:fad/setting.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const UserInfoEdit());
}

class UserInfoEdit extends StatelessWidget {
  const UserInfoEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: EditUserDetails(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EditUserDetails extends StatefulWidget {
  const EditUserDetails({super.key});

  @override
  State<EditUserDetails> createState() => _EditUserState();
}

class _EditUserState extends State<EditUserDetails> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Setting()),
              );
            },
          ),
        ),
        body: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 100,
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
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 12,
                      right: 12,
                    ),
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
                          Icons.account_circle_rounded,
                          size: 30,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        contentPadding: EdgeInsets.only(top: 2, bottom: 2),
                      ),
                    ),
                  ),
                ),
                Material(
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 10, left: 12, right: 12),
                    // padding: const EdgeInsets.all(12),
                    // width: MediaQuery.of(context).size.width * 1,
                    color: Colors.blue,
                    child: TextField(
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.email,
                          size: 24,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        contentPadding: EdgeInsets.only(top: 2, bottom: 2),
                      ),
                    ),
                  ),
                ),
                Material(
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 10, left: 12, right: 12),
                    // padding: const EdgeInsets.all(12),
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
                        contentPadding: EdgeInsets.only(top: 2, bottom: 2),
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
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Save',
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
