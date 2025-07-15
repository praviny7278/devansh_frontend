import 'dart:convert';

import 'package:fad/productPage/fav_items.dart';
import 'package:fad/productPage/order_history.dart';
import 'package:fad/sessionManager/sessionmanager.dart';
import 'package:fad/user_info_edit.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'auth/login.dart';
import 'homePage/homepage.dart';

void main() {
  runApp(const Setting());
}

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      themeMode: ThemeMode.light,
      home: MySettings(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MySettings extends StatefulWidget {
  const MySettings({super.key});

  @override
  State<MySettings> createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  final SessionManager _sessionManager = SessionManager();
  String _userId = '';
  String _customerName = 'Hello!';
  bool _isLoggedIn = false;





  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getUserId();
    _getUserLogStatus();
  }


  /// Show the error
  Future<void> _onError(String message) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// Launch WhatsApp chat for a specific phone number.
  Future<void> _launchURL(String phoneNumber) async {
    final url = 'https://wa.me/$phoneNumber';

    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw ('Could not launch WhatsApp.');
      }
    } catch (e) {
      print("Error launching WhatsApp: $e");
      _onError(e.toString());
    }
  }

  /// Get user id from session manager
  Future<void> _getUserId() async {
    try {
      final id = await _sessionManager.getUserId();

      if (id != null && id.isNotEmpty) {
        setState(() {
          _userId = id;
        });

        await _getUserDetails();
      } else {
        throw ('Login first!');
      }
    } catch(e) {
      _onError(e.toString());
    }
  }

  /// Get user id from session manager
  Future<void> _getUserLogStatus () async {
    try {
      final status = await _sessionManager.getLoginStatus();

      if (status) {
        setState(() {
          _isLoggedIn = status;
        });
      } else {
        throw ('Login first!');
      }
    } catch(e) {
      _onError(e.toString());
    }
  }

  /// Get user details
  Future<void> _getUserDetails() async {
    // print('ID :  $_userId');
    // print('log Stat : $_isLoggedIn');
    try {
      final response = await http.get(
        Uri.parse('http://175.111.182.125:8082/customer/v1/$_userId'),
        headers: {
          'Authorization': 'Bearer Token',
          'Content-Type': 'application/json',
        }
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> customerDetails = jsonDecode(response.body);
        if (response.body.isNotEmpty) {
          setState(() {
            _customerName =  customerDetails['firstName'] ?? 'Hello!';
          });
        } else {
          throw ('Empty body!');
        }
      }else if (response.statusCode == 401) {
        throw ('Unauthorized: Invalid token');
      }
      else {
        throw ('Failed to load data: ${response.reasonPhrase}');
      }
    } catch(e) {
       print('Failed to load data: $e');
      _onError(e.toString());
    }
  }

  /// Click happen on Login avatar
  Future<void> _onClickLogin() async {
    /// Remove the current page
    Navigator.of(context).pop();

    /// Navigate to next page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }



  @override
  Widget build(BuildContext context) {
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

        extendBodyBehindAppBar: false,
        resizeToAvoidBottomInset: false,
        extendBody: true,

        appBar: AppBar(
          title: const Text(''),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _onClickLogin();
            },
          ),
          actions: [

            /// User title
            Container(
              margin: const EdgeInsets.only(right: 10),
              child:  Text(
                  _customerName,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),

            /// User avatar
            GestureDetector(
              onTap: () {

                /// checking the status
                if (_isLoggedIn) {

                  /// Navigate to the next page according to the condition
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserInfoEditPage(),
                    ),
                  );
                } else {

                  /// Navigate to the next page according to the condition
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                }
              },

              /// User avatar
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                alignment: Alignment.center,
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: NetworkImage('assets/user-avatar.png'),
                    fit: BoxFit.fill,
                  ), // Handle null image
                ),
              ),
            )
          ],
        ),

        /// All setting options
        body: RefreshIndicator(

          color: Colors.red,
          backgroundColor: Colors.red,
          onRefresh: () async {
            print('object');
            /// initiate
            await _getUserId();
            await _getUserLogStatus();
            await _onClickLogin();
            await _getUserDetails();

          },
          child: Container(
            padding: const EdgeInsets.only(left: 9, right: 9),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                /// Navigate to user details edit page
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserInfoEditPage()),
                    );
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.only(top: 14, bottom: 14, left: 9),
                    margin: const EdgeInsets.only(
                      top: 5,
                      bottom: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.27),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.white,
                          Colors.white,
                          Colors.white,
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.person),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: const Text(
                            "Personal Details",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// Navigate to wishlist page
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FavoriteProducts()));
                  },
                  child: Container(
                      padding:
                      const EdgeInsets.only(top: 14, bottom: 14, left: 9),
                      margin: const EdgeInsets.only(
                        top: 5,
                        bottom: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text(
                              "Favorite",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      )),
                ),

                /// Navigate to oder history page
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderList(),
                      ),
                    );
                  },
                  child: Container(
                      padding:
                      const EdgeInsets.only(top: 14, bottom: 14, left: 9),
                      margin: const EdgeInsets.only(
                        top: 5,
                        bottom: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.list_alt_sharp),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text(
                              "Orders and payments",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      )),
                ),

                /// Navigate to whatsApp
                GestureDetector(
                  onTap: () {
                    _launchURL('919167692709');
                  },
                  child: Container(
                      padding:
                      const EdgeInsets.only(top: 14, bottom: 14, left: 9),
                      margin: const EdgeInsets.only(
                        top: 5,
                        bottom: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(right: 0),
                            alignment: Alignment.center,
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: const DecorationImage(
                                image: NetworkImage(
                                    'assets/WhatsApp.svg.webp'),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text(
                              "WhatsApp",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      )),
                ),

                /// Navigate to About page
                GestureDetector(
                  onTap: () {},
                  child: Container(
                      padding:
                      const EdgeInsets.only(top: 14, bottom: 14, left: 9),
                      margin: const EdgeInsets.only(
                        top: 5,
                        bottom: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.perm_device_information),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text(
                              "About Us",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      )),
                ),

                /// User log-out
                GestureDetector(
                  onTap: () async {
                    // await _sessionManager.clearSession();
                    // Navigator.pop(context);
                    // Navigator.push(
                    //   context, MaterialPageRoute( builder: (context) => const Home()),
                    // );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Not working now!'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: Container(
                      padding:
                      const EdgeInsets.only(top: 14, bottom: 14, left: 9),
                      margin: const EdgeInsets.only(
                        top: 5,
                        bottom: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.login_outlined),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: const Text(
                              "Log out",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        )
    );
  }
}
