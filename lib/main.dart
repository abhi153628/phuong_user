import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phuong/firebase_options.dart';
import 'package:phuong/repository/search_provider.dart';
import 'package:phuong/services/event_fetching_firebase_service.dart';
import 'package:phuong/view/auth_screens/auth_screen.dart';
import 'package:phuong/view/homepage/widgets/event_carousel/carousel_bloc/bloc/carousel_event.dart';
import 'package:phuong/view/wrapper.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<EventsBloc>(
          create: (context) => EventsBloc(EventService()),
        ),
      
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SearchProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );

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
      title: 'Phuong',
      home:Wrapper(),
    );
  }
}