
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthServices {
  //!signup services
  final _auth=FirebaseAuth.instance;
  Future<User?> createUserEmailAndPassword(String email,String password)async{
    try {
      final cred=await _auth.createUserWithEmailAndPassword(email: email, password: password);
return cred.user;
      
    } catch (e) {
      print('Something went wrong');
      
    }
    return null;


  }


  //!login service
   
  Future<User?> loginUserWithEmailAndPassword(String email,String password)async{
    try {
      final cred=await _auth.signInWithEmailAndPassword(email: email, password: password);
return cred.user;
      
    } catch (e) {
      print('Something went wrong');
      
    }
    return null;


  }

//!sign out

Future<void>signOut()async{
  try {
    _auth.signOut();
    
  } catch (e) {
    print('something went Wrong');
    
  }

  

}


}
