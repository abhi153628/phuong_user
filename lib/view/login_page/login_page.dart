// // File: login_page.dart

// import 'package:flutter/material.dart';
// import 'package:phuong/services/auth_firebase_services.dart';

// import 'package:phuong/view/homepage/homepage.dart';
// import 'package:phuong/utils/cstm_transition.dart';
// import 'package:phuong/view/login_page/login_widget.dart';


// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _auth = FirebaseAuthServices();
//   late Color myColor;
//   late Size mediaSize;
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController(); 
//   bool rememberUser = false;

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     myColor = Colors.black;
//     mediaSize = MediaQuery.of(context).size;
//     return Scaffold(
//       body: Stack(
//         children: [
//           BackgroundImage(),
//           BlackOverlay(),
//           BrandName(),
//           LoginForm(
//             mediaSize: mediaSize,
//             emailController: emailController,
//             passwordController: passwordController,
//             rememberUser: rememberUser,
//             onRememberChanged: (value) => setState(() => rememberUser = value),
//             onLogin: _login,
//           ),
//         ],
//       ),
//     );
//   }

//   _login() async {
//    await _auth.loginUserWithEmailAndPassword(
//         emailController.text, passwordController.text);
   
//   }
// }