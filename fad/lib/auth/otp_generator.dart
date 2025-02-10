import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../user_info.dart';
import 'number_input.dart';

void main() {
  runApp(
    MaterialApp(
      // theme: ThemeData(colorScheme:  ColorScheme(brightness: 12, primary: null, onPrimary: null, secondary: null, onSecondary: null, error: null, onError: null, surface: null, onSurface: null)),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Pinput Example'),
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        body: const FractionallySizedBox(
          widthFactor: 0.8,
          child: OtpGenerator(),
        ),
      ),
    ),
  );
}

class OtpGenerator extends StatefulWidget {
  const OtpGenerator({super.key});

  @override
  State<OtpGenerator> createState() => _PinputExampleState();
}

class _PinputExampleState extends State<OtpGenerator> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
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

    return Stack(
      children: <Widget>[
        Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Material(
                      color: Colors.white,
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
                          return value == '222222' ? null : 'Invalid OTP';
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
                              width: 22,
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
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(color: focusedBorderColor),
                          ),
                        ),
                        errorPinTheme: defaultPinTheme.copyBorderWith(
                          border: Border.all(color: Colors.redAccent),
                        ),
                      )),
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
                          builder: (context) => const NumberTextField()),
                    );
                  },
                  child: const Text('Resend OTP'),
                ),
              ),
            ],
          ),
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
                  focusNode.unfocus();
                  if (formKey.currentState!.validate()) {
                    debugPrint("ok");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserInfo()),
                    );
                  }
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
    );
  }
}
