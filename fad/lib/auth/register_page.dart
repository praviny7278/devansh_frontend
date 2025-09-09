import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:fad/auth/login.dart';
import 'package:fad/network_check.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(const UserRegisterPage());
}

class UserRegisterPage extends StatelessWidget {
  const UserRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RegisterPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firsNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _buildingNameController = TextEditingController();
  final _cityNameController = TextEditingController();
  final _areaNameController = TextEditingController();
  final _pinCodeController = TextEditingController();

  ///
  final NetworkService _network = NetworkService();

  /// register URL for the user/customer
  final String userRegUrl = 'http://175.111.182.125:8082/customer/v1/customer';
  bool _isLoading = false;
  bool _isNewUserRegistered = false;
  bool _isButtonEnabled = false;



  /// Error message
  Future<void> _onError() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Something went wrong!'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }





  ///
  /// function for the New User Registration
  Future<void> userRegister (Map<String, dynamic> newUserDetails) async {
    try {

      String jsonBody = jsonEncode(newUserDetails);

      final response = await http.post(
          Uri.parse(userRegUrl),
          headers: {
            'Authorization': 'Bearer-Token',
            'Content-Type': 'application/json',
          },
          body: jsonBody
      );

      if (response.statusCode == 200) {
        // print(response.body);
        setState(() {
          _isLoading = false;
          _isNewUserRegistered = true;
        });
      } else {
        throw ('Server returned status code: ${response.statusCode}');
      }

    }on SocketException {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet connection'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
        _isNewUserRegistered = false;
      });
      _onError();
    }
  }

  /// handling all input text field when something get change
  void _handleInputChange() {
    setState(() {
      _isButtonEnabled =
          _firsNameController.text.isNotEmpty &&
              _lastNameController.text.isNotEmpty &&
              _phoneController.text.isNotEmpty &&
              _emailController.text.isNotEmpty &&
              _buildingNameController.text.isNotEmpty &&
              _areaNameController.text.isNotEmpty &&
              _cityNameController.text.isNotEmpty &&
              _pinCodeController.text.isNotEmpty;
    });
  }

  /// on Register successfully
  void showCustomSuccessDialog(BuildContext context) {
    BuildContext? dialogContext;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        dialogContext ??= context; // Capture dialog context only once

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(seconds: 2), () {
            if (dialogContext != null && Navigator.of(dialogContext!).canPop()) {
              Navigator.of(dialogContext!).pop();// Now safe
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          });
        });

        return Transform.scale(
          scale: animation.value,
          child: Opacity(
            opacity: animation.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text("Success"),
                ],
              ),
              content: const Text("Registration completed successfully."),
            ),
          ),
        );
      },
    );
  }


  @override
  void dispose() {
    _firsNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _buildingNameController.dispose();
    _areaNameController.dispose();
    _cityNameController.dispose();
    _pinCodeController.dispose();
    _networkService.dispose();
    super.dispose();
  }

  late final NetworkService _networkService;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService();
    _networkService.startMonitoring((result) {
      if (result == ConnectivityResult.none) {
        print("❌ No internet connection");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No internet connection")),
        );
      } else {
        print("✅ Connected via ${result.name}");
      }
    });
  }





  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * 1,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            /// background image
              image: DecorationImage(
                  image: AssetImage('assets/milk.jpg'),
                  fit: BoxFit.fitHeight
              )
          ),
          /// Glass morphic container for the better UI
          child: GlassmorphicContainer(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 1,
            borderRadius: 10,
            blur: 14,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.5)],
            ),

            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWideScreen ? 500 : double.infinity),
                /// User register form
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment:MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      /// First Name text field
                      TextFormField(
                        controller: _firsNameController,
                        onChanged: (_)=> _handleInputChange(),
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) =>
                        value!.isEmpty ? 'Enter your first name' : null,
                      ),

                      const SizedBox(height: 12),

                      /// Last Name text field
                      TextFormField(
                        controller: _lastNameController,
                        onChanged: (_)=> _handleInputChange(),
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) =>
                        value!.isEmpty ? 'Enter your last name' : null,
                      ),

                      const SizedBox(height: 12),

                      /// Email text field
                      TextFormField(
                        controller: _emailController,
                        onChanged: (_)=> _handleInputChange(),
                        decoration: const InputDecoration(
                          labelText: 'Email',

                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          return emailRegex.hasMatch(value ?? '')
                              ? null
                              : 'Enter a valid email';
                        },
                      ),

                      const SizedBox(height: 12),

                      /// Phone number text field
                      TextFormField(
                        controller: _phoneController,
                        onChanged: (_)=> _handleInputChange(),
                        decoration:
                        const InputDecoration(
                          labelText: 'Phone Number',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        validator: (value) => value!.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(value)
                            ? null
                            : 'Enter a valid 10-digit number',
                      ),

                      const SizedBox(height: 12),

                      /// House no. text field
                      TextFormField(
                        controller: _buildingNameController,
                        onChanged: (_)=> _handleInputChange(),
                        decoration: const InputDecoration(
                          labelText: 'House No.',
                        ),
                        validator: (value) => value!.isEmpty? 'Enter House No.' : null,
                      ),

                      const SizedBox(height: 12),

                      /// Area Name text field
                      TextFormField(
                        controller: _areaNameController,
                        onChanged: (_)=> _handleInputChange(),
                        decoration: const InputDecoration(
                          labelText: 'Area',
                          // suffixIcon: IconButton(
                          // ),
                        ),
                        validator: (value) => value!.isEmpty? 'Enter Your Area.' : null,
                      ),

                      const SizedBox(height: 12),

                      /// City Name text field
                      TextFormField(
                        controller: _cityNameController,
                        onChanged: (_)=> _handleInputChange(),
                        decoration: const InputDecoration(
                          labelText: 'City',
                          // suffixIcon: IconButton(
                          // ),
                        ),
                        validator: (value) => value!.isEmpty? 'Enter Your City.' : null,
                      ),

                      const SizedBox(height: 12),

                      /// Pin code text field
                      TextFormField(
                        controller: _pinCodeController,
                        onChanged: (_)=> _handleInputChange(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Pin code',
                          // suffixIcon: IconButton(
                          // ),
                        ),
                        validator: (value) => value!.length == 6 ? null : '6 Digit only',
                      ),

                      const SizedBox(height: 24),

                      /// Register button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isButtonEnabled ?
                              () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              /// All input data mapping here
                              Map<String, dynamic> newUserData = {
                                'firstName' : _firsNameController.text,
                                'lastName' : _lastNameController.text,
                                'mobileNo' : _phoneController.text,
                                'emailId' : _emailController.text,
                                "status": true,
                                'address' : {
                                  // "addressId": "12",
                                  'buildingName' : _buildingNameController.text,
                                  'locality' : _areaNameController.text,
                                  'city' : _cityNameController.text,
                                  'pincode' : _pinCodeController.text,
                                  'streetNo' : '',
                                },
                              };
                              print(newUserData);

                              /// function call
                              await userRegister(newUserData);
                              if (_isNewUserRegistered) {
                                showCustomSuccessDialog(context);
                              }


                              /// Show the notification
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Registering user...'),
                                ),
                              );
                            }
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
