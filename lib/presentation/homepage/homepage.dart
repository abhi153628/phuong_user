import 'package:flutter/material.dart';
import 'package:phuong/core/constants/transition.dart';
import 'package:phuong/data/datasources/firebase_auth_services.dart';
import 'package:phuong/presentation/login_page/login_page.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final _auth =FirebaseAuthServices();
    return  Center(
      child: ElevatedButton(onPressed: ()async{  await _auth.signOut();
       Navigator.of(context)
                        .push(GentlePageTransition(page: LoginPage()));
      }, child: Text('signOut')),
    );
  }
}
