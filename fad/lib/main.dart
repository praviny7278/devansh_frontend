import 'dart:convert';

import 'package:fad/auth/register_page.dart';
import 'package:fad/homePage/homepage.dart';
import 'package:fad/productPage/check_out_page.dart';
import 'package:fad/productPage/order_history.dart';
import 'package:fad/productPage/order_list_item_history.dart';
import 'package:fad/productSubscriptions/subscription_product.dart';
import 'package:fad/sessionManager/sessionmanager.dart';
import 'package:fad/setting.dart';
import 'package:fad/splashScreen/splash_screen.dart';
import 'package:fad/user_info_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
//
import 'auth/login.dart';
import 'auth/otp_validation.dart';
//
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize notification channel
//   await AwesomeNotifications().initialize(
//     null,
//     [
//       NotificationChannel(
//         channelKey: 'basic',
//         channelName: 'Basic Notifications',
//         channelDescription: 'Channel for test notifications',
//         importance: NotificationImportance.High,
//       )
//     ],
//   );
//
//   // Request permission if not granted
//   if (!await AwesomeNotifications().isNotificationAllowed()) {
//     await AwesomeNotifications().requestPermissionToSendNotifications();
//   }
//
//   // Listen for notification taps
//   AwesomeNotifications().setListeners(
//     onActionReceivedMethod: (receivedAction) async {
//       if (receivedAction.buttonKeyPressed == 'ACCEPT') {
//         debugPrint("✅ User pressed Accept");
//       } else if (receivedAction.buttonKeyPressed == 'REJECT') {
//         debugPrint("❌ User pressed Reject");
//       } else {
//         debugPrint("🔔 Notification body tapped");
//         // 👉 For MIUI: show dialog when body is tapped
//         MyApp.navigatorKey.currentState?.push(
//           MaterialPageRoute(
//             builder: (_) => const DecisionDialog(),
//           ),
//         );
//       }
//     },
//   );
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   static final GlobalKey<NavigatorState> navigatorKey =
//   GlobalKey<NavigatorState>();
//
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       debugShowCheckedModeBanner: false,
//       home: const HomePage(),
//     );
//   }
// }
//
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//
//   Future<void> _showNotification() async {
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 1,
//         channelKey: 'basic',
//         title: 'Friend Request',
//         body: 'Do you want to accept?',
//       ),
//       actionButtons: [
//         NotificationActionButton(
//           key: 'ACCEPT',
//           label: '✅ Accept',
//         ),
//         NotificationActionButton(
//           key: 'REJECT',
//           label: '❌ Reject',
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Notification Test')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _showNotification,
//           child: const Text("Send Notification"),
//         ),
//       ),
//     );
//   }
// }
//
// class DecisionDialog extends StatelessWidget {
//   const DecisionDialog({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text("Friend Request"),
//       content: const Text("Do you want to accept this request?"),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//             debugPrint("✅ User accepted (via dialog)");
//           },
//           child: const Text("Accept"),
//         ),
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//             debugPrint("❌ User rejected (via dialog)");
//           },
//           child: const Text("Reject"),
//         ),
//       ],
//     );
//   }
// }




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  /// OneSignal config
  OneSignal.initialize('0b422fec-006a-4c2c-8c3d-9ece719f6164');
  OneSignal.Notifications.requestPermission(true); // Ask user permission

// Foreground handler (custom UI while app is open)
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    // event.preventDefault(); // stop default OneSignal banner
    // OneSignal.Notifications.displayNotification(event.notification); // show system-style notification
  });







  // OneSignal.Notifications.addForegroundWillDisplayListener((event) {
  //   event.preventDefault(); // Stop default banner
  //
  //   // Use your Flutter widget to display custom UI
  //   showDialog(
  //     context: navigatorKey.currentContext!,
  //     builder: (_) => AlertDialog(
  //       title: Text(event.notification.title ?? "Notification"),
  //       content: Text(event.notification.body ?? ""),
  //       actions: [
  //         TextButton(
  //           onPressed: (){},
  //           // onPressed: () => Navigator.pop(context),
  //           child: Text("Close"),
  //         ),
  //       ],
  //     ),
  //   );
  // });





  // 🔔 Initialize notifications before running app
  // await initializeNotifications();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductSubscriptionsPage(),
    );
  }
}




class DatePickerDemo extends StatefulWidget {
  const DatePickerDemo({super.key});

  @override
  State<DatePickerDemo> createState() => _DatePickerDemoState();
}

class _DatePickerDemoState extends State<DatePickerDemo> {
  DateTime? _selectedDate;

  // Function to show Date Picker
  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Default: today
      firstDate: DateTime(2000), // Earliest date
      lastDate: DateTime(2100),  // Latest date
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Date Picker Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedDate == null
                  ? "No date selected"
                  : "Selected: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            IconButton(
                onPressed: _pickDate,
                icon: Icon(Icons.calendar_month_outlined),
            )
          ],
        ),
      ),
    );
  }
}


// import 'package:fad/widget/error_throw_widget.dart';
// import 'package:flutter/material.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Error Widget Example')),
//         body: const MyScreen(),
//       ),
//     );
//   }
// }
//
// class MyScreen extends StatefulWidget {
//   const MyScreen({super.key});
//
//   @override
//   _MyScreenState createState() => _MyScreenState();
// }
//
// class _MyScreenState extends State<MyScreen> {
//   bool hasError = true; // Simulate an error for demonstration
//
//   Future<void> fetchData() async {
//     print('object');
//     setState(() {
//       hasError = false; // Simulate a retry removing the error
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (hasError) {
//       return ErrorThrowWidget(
//         errorMessage: 'An error occurred while loading the data.',
//         onRetry: fetchData,
//       );
//     }
//
//     // Replace with your actual UI when there's no error
//     return Center(
//       child: Text(
//         'Data loaded successfully!',
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
// }

//
// import 'package:flutter/material.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: HideContainerExample(),
//     );
//   }
// }
//
// class HideContainerExample extends StatefulWidget {
//   @override
//   _HideContainerExampleState createState() => _HideContainerExampleState();
// }
//
// class _HideContainerExampleState extends State<HideContainerExample> {
//   bool isVisible = true; // Tracks the visibility of the Container
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Hide Container Example"),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (isVisible) // Only include the Container if `isVisible` is true
//             Container(
//               height: 200,
//               width: 200,
//               color: Colors.blue,
//               child: Center(
//                 child: Text(
//                   "I'm a container!",
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               ),
//             ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 isVisible = !isVisible; // Toggle the visibility
//               });
//             },
//             child: Text(isVisible ? "Hide Container" : "Show Container"),
//           ),
//         ],
//       ),
//     );
//   }
// }
