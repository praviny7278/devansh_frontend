import 'package:flutter/material.dart';

class SnackbarUtils {
  static void showErrorSnackBar({
    required BuildContext context,
    required String message,
    required VoidCallback onRetry,
    Duration duration = const Duration(hours: 1), // Default duration
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: onRetry,
        ),
        duration: duration,
      ),
    );
  }
}

//
// class ErrorThrowWidget extends StatelessWidget {
//   final String errorMessage;
//   final VoidCallback onRetry;
//
//   const ErrorThrowWidget(
//       {super.key, required this.errorMessage, required this.onRetry});
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return Container(
//       width: 250,
//       height: 300,
//       alignment: Alignment.center,
//       color: Colors.transparent,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           Text(errorMessage),
//           TextButton(
//             onPressed: onRetry,
//             child: const Text('Retry'),
//           )
//         ],
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
//
// class ErrorWidgetWithRetry extends StatelessWidget {
//   final String errorMessage;
//   final VoidCallback onRetry;
//
//   const ErrorWidgetWithRetry({
//     Key? key,
//     required this.errorMessage,
//     required this.onRetry,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             color: Colors.red,
//             size: 50,
//           ),
//           const SizedBox(height: 10),
//           Text(
//             errorMessage,
//             style: const TextStyle(
//               fontSize: 16,
//               color: Colors.black54,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: onRetry,
//             icon: const Icon(Icons.refresh),
//             label: const Text('Retry'),
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
