import 'dart:convert';

import 'package:fad/sessionManager/sessionmanager.dart';
import 'package:fad/setting.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;





void main() {
  runApp(const UserInfoEditPage());
}

class UserInfoEditPage extends StatelessWidget {
  const UserInfoEditPage({super.key});

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
  final SessionManager _sessionManager = SessionManager();

  final _formKey = GlobalKey<FormState>();
  final _firsNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _buildingNameController = TextEditingController();
  final _cityNameController = TextEditingController();
  final _areaNameController = TextEditingController();
  final _pinCodeController = TextEditingController();


  Map<String, dynamic> _userData = {};


  bool _isLoading = false;
  String _userId = '';
  bool _isUserUpdateSuccess = false;







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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    getUserId();
    getUserInfo();
  }


  // /// handling all input text field when something get change
  // void _handleInputChange() {
  //   setState(() {
  //     _isButtonEnabled =
  //         _firsNameController.text.isNotEmpty &&
  //             _lastNameController.text.isNotEmpty &&
  //             _phoneController.text.isNotEmpty &&
  //             _emailController.text.isNotEmpty &&
  //             _buildingNameController.text.isNotEmpty &&
  //             _areaNameController.text.isNotEmpty &&
  //             _cityNameController.text.isNotEmpty &&
  //             _pinCodeController.text.isNotEmpty;
  //   });
  // }


  /// on Error message
  Future<void> _onError(String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }


  /// on Successfully message
  Future<void> _onSuccess(String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.greenAccent,
      ),
    );
  }


  /// Get User Id
  Future<void> getUserId() async {
    try {
      String? id = await _sessionManager.getUserId();

      if (id != null) {
        setState(() {
          _userId = id;
        });
      } else {
        throw ('Login first!');
      }

    } catch(e) {
      _onError('$e');
      print(e);
    }
  }

  ///  Update User details
  Future<void> userUpdate (Map<String, dynamic> newUserDetails) async {
    final String userRegUrl = 'http://175.111.182.125:8082/customer/v1/$_userId';

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
          _isUserUpdateSuccess = true;
        });
        _onSuccess('Your data has been successfully updated.');
      } else {
        throw ('Server returned status code: ${response.statusCode}');
      }

    }catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
      _onError('$e');
    }
  }

  /// Get User details
  Future<void> getUserInfo() async {
    final String userUrl = 'http://175.111.182.125:8082/customer/v1/$_userId';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
          Uri.parse(userUrl),
        headers: {
            'Authorization' : 'Bearer token',
            'Content-Type' : 'application/json'
        },
      );

      if (response.statusCode == 200) {

        if (response.body.isNotEmpty) {
          setState(() {
            _userData = jsonDecode(response.body);
            _isLoading = false;

            ///
            _firsNameController.text = _userData['firstName'] ?? '';
            _lastNameController.text = _userData['lastName'] ?? '';
            _phoneController.text = _userData['mobileNo'] ?? '';
            _emailController.text = _userData['emailId'] ?? '';
            _buildingNameController.text = _userData['address'][0]['buildingName'] ?? '';
            _areaNameController.text = _userData['address'][0]['locality'] ?? '';
            _cityNameController.text = _userData['address'][0]['city'] ?? '';
            _pinCodeController.text = _userData['address'][0]['pincode'] ?? '';

          });
        }

        print(_userData);
      } else if (response.statusCode == 204) {
        throw ('User not found!');
      } else if (response.statusCode == 404) {
        throw ('Something went wrong!');
      } else {
        throw ('Something went wrong!');
      }

    } catch(e) {
      print(e);
      _onError(e.toString());
    }
  }




  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

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
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 5),
              child: const TextButton(
                onPressed: null,
                // onPressed: () async {
                // //
                // //   Map<String, dynamic> userDetails = {
                // //     'firstName': _firsNameController.text,
                // //     'lastName': _lastNameController.text,
                // //     'mobileNo': _phoneController.text,
                // //     'emailId': _emailController.text,
                // //     'address': {
                // //       'streetNo': '',
                // //       'buildingName': _buildingNameController.text,
                // //       'locality': _areaNameController.text,
                // //       'city': _cityNameController.text,
                // //       'pincode': _pinCodeController.text,
                // //     }
                // //   };
                //
                //   ///
                //   // await userUpdate(userDetails);
                //   // if (_isUserUpdateSuccess) {
                //   //
                //   // } else {
                //   //   _onError('Something went wrong! Please try again later.');
                //   // }
                //
                //  },
                child: Text('Save'),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWideScreen ? 500 : double.infinity),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment:MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  /// First Name text field
                  TextFormField(
                    controller: _firsNameController,
                    // onChanged: (_)=> _handleInputChange(),
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
                    // onChanged: (_)=> _handleInputChange(),
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
                    // onChanged: (_)=> _handleInputChange(),
                    decoration: const InputDecoration(
                      labelText: 'Email',

                    ),
                    keyboardType: TextInputType.emailAddress,
                    // validator: (value) {
                    //   final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    //   return emailRegex.hasMatch(value ?? '')
                    //       ? null
                    //       : 'Enter a valid email';
                    // },
                  ),

                  const SizedBox(height: 12),

                  /// Phone number text field
                  TextFormField(
                    controller: _phoneController,
                    // onChanged: (_)=> _handleInputChange(),
                    decoration:
                    const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                  ),

                  const SizedBox(height: 12),

                  /// House no. text field
                  TextFormField(
                    controller: _buildingNameController,
                    // onChanged: (_)=> _handleInputChange(),
                    decoration: const InputDecoration(
                      labelText: 'House No.',
                    ),
                    validator: (value) => value!.isEmpty? 'Enter House No.' : null,
                  ),

                  const SizedBox(height: 12),

                  /// Area Name text field
                  TextFormField(
                    controller: _areaNameController,
                    // onChanged: (_)=> _handleInputChange(),
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
                    // onChanged: (_)=> _handleInputChange(),
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
                    // onChanged: (_)=> _handleInputChange(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pin code',
                      // suffixIcon: IconButton(
                      // ),
                    ),
                    validator: (value) => value!.length == 6 ? null : '6 Digit only',
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
