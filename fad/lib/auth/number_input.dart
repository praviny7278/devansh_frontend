import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'otp_generator.dart';

void main() {
  runApp(const NumberTextField());
}

class NumberTextField extends StatelessWidget {
  const NumberTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  // void _onFocusChange() {
  //   setState(() {
  //     _isFocused = _focusNode.hasFocus;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // Calculate the width of the screen
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(''),
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 250,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    // color: Colors.red,
                    image: const DecorationImage(
                        image: AssetImage('assets/milk.jpg'), fit: BoxFit.fill),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 18),
                        alignment: Alignment.topLeft,
                        // color: Colors.blue,
                        child: const Text(
                          "Enter your mobile number",
                          style: TextStyle(
                              fontSize: 33, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text(
                        "We need to verify you. We will send you a one-time verification code.",
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TextField(
                          // controller: _textEditingController,
                          // focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: "XXX XXX 0000",
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.green,
                                width: 1,
                              ),
                            ),
                            prefixIcon: Icon(Icons.call),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.purple, width: 2),
                            ),
                            labelStyle: TextStyle(
                              fontSize: 26,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          style: const TextStyle(fontSize: 25),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 15,
            left: 0, // Align the button to the left edge
            right: 0, // Align the button to the right edge
            child: Container(
              height: 55,
              alignment: Alignment.center,
              color: Colors.white,
              child: FractionallySizedBox(
                alignment: Alignment.center,
                widthFactor: 0.9, // Set the width factor to 90%
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const OtpGenerator()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    // Center the text and icon horizontally
                    alignment: Alignment.center,
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    textAlign: TextAlign.center,
                    'Next',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
