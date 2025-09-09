import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:fad/auth/register_page.dart';
import 'package:fad/sessionManager/sessionmanager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;


import 'otp_validation.dart';

void main() {
  runApp(const LoginPage());
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: LoginInput());
  }
}

class LoginInput extends StatefulWidget {
  const LoginInput({super.key});

  @override
  State<LoginInput> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<LoginInput> {
  final TextEditingController _textEditingController = TextEditingController();
  final SessionManager _sessionManager = SessionManager();

  final String baseURL = 'http://175.111.182.125:9095/auth/v1/send-otp';

  Color borderColor = const Color(0xFF00CC00);// Default: green
  bool isLoading = false;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }


  /// set user mobile number
  Future<void> setMobNumber (String number) async {
    await _sessionManager.setUserMobNumber(number);
  }

  /// Error message
  Future<void> onError() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Something went wrong!'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
  
  /// function for mobile number verification
  Future<bool> mobileNumberValidation(String number) async {
    try {
      final response = await http.post(
        Uri.parse(baseURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'mobileNumber': number}),
      );
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        print(response.body);
        await setMobNumber(number);
        return true;
       }
      else if (response.statusCode == 500) {
          throw ('Server returned status code: ${response.statusCode}');
        // setState(() {
        //   isLoading = false;
        // });
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Something went wrong!'),
        //     backgroundColor: Colors.redAccent,
        //   ),
        // );
      }
      else {
        throw ('Server returned status code: ${response.statusCode}');
        // setState(() {
        //   isLoading = false;
        // });
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Something went wrong!'),
        //     backgroundColor: Colors.redAccent,
        //   ),
        // );
      }
    }on SocketException {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet connection'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }
    catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      onError();
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
           decoration: const BoxDecoration(
             /// background image
             image: DecorationImage(
               image: AssetImage('assets/milk.jpg'),
               fit: BoxFit.fill
             )
           ),
            /// Glossy container
            child:  Center(
              // heightFactor: 0.4,
              child: GlassContainer(
                width: MediaQuery.of(context).size.width * 0.9,
                // height: MediaQuery.of(context).size.width * 0.9,
                /// Number input field and otp button
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(),)
                    :Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        /// Number input field container
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          alignment: Alignment.topLeft,
                          // color: Colors.blue,
                          /// Title
                          child: const Text(
                            "Enter your mobile Number",
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ),
                        /// Title
                        const Text(
                          "We need to verify you. We will send you a One-Time verification code.",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        /// Number input field
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                          child: TextField(
                            controller: _textEditingController,
                            // focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: "XXX XXX 0000",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: borderColor,
                                  width: 1,
                                ),
                              ),
                              prefixIcon: const Icon(Icons.call),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple, width: 2),
                              ),
                              labelStyle: const TextStyle(
                                fontSize: 21,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                            ),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),

                    /// OTP generate button Container and next page navigation
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      // padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green,
                      ),
                      child: TextButton(
                        onPressed:  () async {
                          if (_textEditingController.text.length == 10) {
                            setState(() {
                              borderColor = const Color(0xFF00CC00);
                              isLoading = true;
                            }); // Green

                            /// checking the OTP validation and navigate the page route according
                            bool isValid = await mobileNumberValidation(_textEditingController.text);
                            if (isValid) {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OtpValidationPage(),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a valid mobile number"),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            setState(() {
                              borderColor = const Color(0xFFFF3333); // Red
                            });
                          }
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    /// Sign up button Container and next page navigation
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Don't have account?",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                              onPressed:  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Click here",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ) ,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final double width;
  // final double height;
  final Widget child;

  const GlassContainer({
    super.key,
    required this.width,
    // required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          // height: height,
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),

      ),
    );
  }
}
