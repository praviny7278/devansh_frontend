import 'package:fad/productPage/fav_items.dart';
import 'package:fad/productPage/order_history.dart';
import 'package:fad/user_info_edit.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    // TODO: implement build
    throw UnimplementedError();
  }
}

class MySettings extends StatefulWidget {
  const MySettings({super.key});

  @override
  State<MySettings> createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _launchURL(String phoneNumber) async {
    final url = 'https://wa.me/$phoneNumber';
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch WhatsApp Web.';
      }
    } on Exception catch (e) {
      // Display an error message to the user
      print("Error launching WhatsApp Web: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            },
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              child: const Text(
                "User",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserInfoEdit()));
              },
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                alignment: Alignment.center,
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: 'assets/user-avatar.png' != null
                      ? const DecorationImage(
                          image: NetworkImage('assets/user-avatar.png'),
                          fit: BoxFit.fill,
                        )
                      : null, // Handle null image
                ),
              ),
            )
          ],
        ),
        body: Container(
          padding: const EdgeInsets.only(left: 9, right: 9),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserInfoEdit()),
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
                    )),
              ),
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderHistory(),
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
                            image: 'assets/WhatsApp.svg.webp' != null
                                ? const DecorationImage(
                                    image: NetworkImage(
                                        'assets/WhatsApp.svg.webp'),
                                    fit: BoxFit.fill,
                                  )
                                : null, // Handle null image
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
            ],
          ),
        ));
  }
}
