import 'package:flutter/material.dart';

void main() {
  runApp(const UserFeedback());
}

class UserFeedback extends StatelessWidget {
  const UserFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ViewUserFeedback(),
    );
  }
}

class ViewUserFeedback extends StatefulWidget {
  const ViewUserFeedback({super.key});

  @override
  State<ViewUserFeedback> createState() => ViewProductState();
}

class ViewProductState extends State<ViewUserFeedback> {
  final TextEditingController searchController = TextEditingController();

  late List<bool> _starSelected;

  @override
  void initState() {
    super.initState();
    _starSelected = List<bool>.filled(5, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 20),
                child: const Text('Please share your experience with us',
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 30),
                // padding: const EdgeInsets.only(left: 20),
                width: MediaQuery.of(context).size.width * 0.9,
                // color: Colors.green,
                child: const Text(
                  "2",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    onPressed: () {
                      setState(() {
                        // for (int i = 0; i <= index; i++) {
                        _starSelected[index] = !_starSelected[index];
                        // }
                      });
                    },
                    icon: Icon(
                      _starSelected[index] ? Icons.star : Icons.star_border,
                      color: _starSelected[index] ? Colors.yellow : Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                // height: 55,
                margin: const EdgeInsets.only(top: 30),
                // padding: const EdgeInsets.only(left: 10),
                width: MediaQuery.of(context).size.width * 0.9,
                // color: Colors.green,
                child: const TextField(
                  maxLines: 4, // Allows input across multiple lines
                  keyboardType:
                      TextInputType.multiline, // Specifies multiline input
                  decoration: InputDecoration(
                    // prefixIcon: Icon(Icons.search),
                    hintText: 'Enter your text here',
                    border: OutlineInputBorder(), // Optional border decoration
                  ),
                  style: TextStyle(fontSize: 19),
                ),
              ),
            ],
          ),
          Positioned(
              bottom: 70,
              left: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: () {
                  print('Button clicked!');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  // Customize the button color here
                  backgroundColor: Colors.blue,
                ),
                child: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    color: Colors.green,
                  ),
                  padding: const EdgeInsets.all(10),
                  // height: 50,
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 19, color: Colors.white),
                  ),
                ),
              )),
          Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: () {
                  print('Button clicked!');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  // Customize the button color here
                  backgroundColor: Colors.blue,
                ),
                child: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                    color: Colors.orange,
                  ),
                  padding: const EdgeInsets.all(10),
                  // height: 50,
                  child: const Text(
                    "Skip",
                    style: TextStyle(fontSize: 19, color: Colors.white),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
