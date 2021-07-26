// import 'package:flutter/material.dart';
//
// class LoginPage extends StatelessWidget {
//   const LoginPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: CustomColors.firebaseNavy,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.only(
//             left: 16.0,
//             right: 16.0,
//             bottom: 20.0,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             children: [
//               Row(),
//               Expanded(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Flexible(
//                       flex: 1,
//                       child: Image.asset(
//                         'assets/firebase_logo.png',
//                         height: 160,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'FlutterFire',
//                       style: TextStyle(
//                         color:  Colors.yellow,
//                         fontSize: 40,
//                       ),
//                     ),
//                     const Text(
//                       'Authentication',
//                       style: TextStyle(
//                         color:  Colors.orange,
//                         fontSize: 40,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               FutureBuilder(
//                 future: Authentication.initializeFirebase(context: context),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     return Text('Error initializing Firebase');
//                   } else if (snapshot.connectionState == ConnectionState.done) {
//                     return GoogleSignInButton();
//                   }
//                   return const CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Colors.orange,
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
