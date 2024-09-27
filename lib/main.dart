import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:phuong/firebase_options.dart';
import 'package:phuong/presentation/login_page/login_page.dart';
import 'package:phuong/presentation/onboarding_page/onboarding_page.dart';
import 'package:phuong/presentation/welcomepage/welcomes_screen.dart';
import 'package:phuong/presentation/wrapper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  Wrapper()
    );
  }
}
