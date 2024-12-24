import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phuong/firebase_options.dart';
import 'package:phuong/repository/search_provider.dart';
import 'package:phuong/view/homepage/homepage.dart';
import 'package:phuong/view/search_screen/search_page.dart';
import 'package:phuong/view/themes/light_mode.dart';
import 'package:phuong/view/wrapper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Add error handling for Firebase initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SearchProvider())],
      child: const MyApp()));
    SystemChrome.setEnabledSystemUIMode(
  SystemUiMode.edgeToEdge,
  overlays: [],
);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightmode,
      
      //EventSearchScreen()
      //EventsScreen()
      home: Wrapper(),
    );
  }
}


