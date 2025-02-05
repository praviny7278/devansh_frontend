import 'package:fad/homePage/homepage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
    // TODO: implement build
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
