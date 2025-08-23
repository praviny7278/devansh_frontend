import 'dart:convert';
import 'dart:ui';

import 'package:fad/homePage/homepage.dart';
import 'package:fad/sessionManager/sessionmanager.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;


import 'login.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(''),
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        body: const FractionallySizedBox(
          widthFactor: 0.8,
          child: OtpValidationPage(),
        ),
      ),
    ),
  );
}

class OtpValidationPage extends StatefulWidget {
  const OtpValidationPage({super.key});

  @override
  State<OtpValidationPage> createState() => _PinputExampleState();
}

class _PinputExampleState extends State<OtpValidationPage> {
  final pinController = TextEditingController();
  final SessionManager _sessionManager = SessionManager();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  String? _userMobNumber;
  bool _validation = false;
  bool _isLoading = false;
  final baseURL = 'http://localhost:9095/auth/v1/validateOTP';



  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  /// Get User phone number
  Future<void> getUserMobNumber () async {

    try {
      String? phone = await _sessionManager.getUserMobNumber();

      if (phone!= null && phone.isNotEmpty) {
        _userMobNumber = phone;
      } else {
        throw ('Phone Number is Empty!');
      }
    } catch(e) {
      _onError('$e');
    }

    // print(_userMobNumber);
  }

  /// Set User Log in status
  Future<void> setLoginStatus ( bool loginStatus) async {

    try {
      if (loginStatus) {
        await _sessionManager.setLoginStatus(loginStatus);
      } else {
        throw ('Something went wrong!');
      }
    } catch(e) {
      _onError('$e');
    }
    // print(_userMobNumber);
  }


  /// Set User User Id
  Future<void> setUserId(String userId) async {
    try {
      if (userId.isNotEmpty) {
        await _sessionManager.setUserId(userId);
      } else {
        throw ('User not found!');
      }
    } catch(e) {
      _onError('$e');
    }
  }

  /// on Error
  Future<void> _onError(String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }


  Future<bool> otpValidation (String otp) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(baseURL),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {
              'mobileNumber': _userMobNumber,
              'code': otp
            }
        ),
      );
      if (response.statusCode == 200) {

        Map<String, dynamic> resData = {};
        print(response.body);


        setState(() {
          _validation = true;
          _isLoading = false;

          resData = jsonDecode(response.body);
        });


        await setLoginStatus(_validation);

        await setUserId(resData['data']['userId'].toString());

        return true;
      }else {
        throw ('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      setState(() {
        _validation = false;
        _isLoading = false;
      });
      _onError('$e');
      return false;
    }
  }



  @override
  void initState() {
    super.initState();
    getUserMobNumber();
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/milk.jpg'),
                fit: BoxFit.fill,
              ),
            ),
            child: GlassContainer(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.width * 1,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      alignment: Alignment.center,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Material(
                          color: Colors.transparent,
                          child: Pinput(
                            controller: pinController,
                            focusNode: focusNode,
                            androidSmsAutofillMethod:
                            AndroidSmsAutofillMethod.smsUserConsentApi,
                            listenForMultipleSmsOnAndroid: true,
                            defaultPinTheme: defaultPinTheme,
                            // separatorBuilder: (index) => const SizedBox(width: 8),
                            length: 6, // Set the length to 6 for six input fields
                            validator: (value) {
                              if (value != null) {
                                return null;
                              }else {
                                pinController.clear();
                                return 'Invalid OTP';
                              }


                              // return value == '123456' ? null : 'Invalid OTP';
                              // if (value == '123456') {
                              //   return null;
                              // } else {
                              //   pinController.clear();
                              //   return 'Invalid OTP';
                              // }
                            },
                            hapticFeedbackType: HapticFeedbackType.lightImpact,
                            onCompleted: (pin) {
                              debugPrint('onCompleted: $pin');
                            },
                            // onChanged: (value) {
                            //   debugPrint('onChanged: $value');
                            // },
                            cursor: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 9),
                                  width: 15,
                                  height: 1,
                                  color: focusedBorderColor,
                                ),
                              ],
                            ),
                            focusedPinTheme: defaultPinTheme.copyWith(
                              decoration: defaultPinTheme.decoration!.copyWith(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: focusedBorderColor),
                              ),
                            ),
                            submittedPinTheme: defaultPinTheme.copyWith(
                              decoration: defaultPinTheme.decoration!.copyWith(
                                color: fillColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: focusedBorderColor),
                              ),
                            ),
                            errorPinTheme: defaultPinTheme.copyBorderWith(
                              border: Border.all(color: Colors.redAccent),
                            ),
                          ),),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 22.0),
                      child: TextButton(
                        onPressed: () {
                          focusNode.unfocus();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginInput()),
                          );
                        },
                        child: const Text('Resend OTP'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 27,
            right: 27,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.green,
              ),
              child: TextButton(
                onPressed: () async {
                  focusNode.unfocus();
                  final otp = pinController.text;

                  bool valid = await otpValidation(otp);
                  final form = formKey.currentState;

                  print("form is null: ${form == null}");
                  print("form validate: ${form?.validate()}");
                  print("OTP valid: $valid");

                  if (valid) {
                    print("ok");
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));

                  }
                },
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
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
  final double height;
  final Widget child;


  const GlassContainer ({
    super.key,
    required this.width,
    required this.height,
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
          height: height,
          // padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      )
    );
  }



}
