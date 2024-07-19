import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/foundation.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //sign in with email and password
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'Wrong password';
      } else if (e.code == 'user-not-found') {
        return 'No user found with this email';
      } else {
        return e.message;
      }
    } catch (e) {
      return 'An error occurred';
    }
  }

  //signup with email and password
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An error occurred';
    }
  }

  // Method to join a game
  Future<DocumentSnapshot?> joinGame(String gameId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('games').doc(gameId).get();
      if (doc.exists) {
        return doc;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  //sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  //get the current user
  User? get currentUser => _auth.currentUser;
}


// enum AuthState { authenticated, unauthenticated }

// class AuthController with ChangeNotifier {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   late StreamSubscription<User?> _currentAuthedUserSubscription;
//   AuthState _state = AuthState.unauthenticated;

//   AuthController() {
//     _listenToAuthChanges();
//   }

//   AuthState get state => _state;

//   void _listenToAuthChanges() {
//     _currentAuthedUserSubscription =
//         _firebaseAuth.userChanges().listen(_handleUserChanges);
//   }

//   void _handleUserChanges(User? user) {
//     if (user == null) {
//       _state = AuthState.unauthenticated;
//     } else {
//       _state = AuthState.authenticated;
//     }
//     notifyListeners();
//   }

//   Future<void> login({required String email, required String password}) async {
//     try {
//       await _firebaseAuth.signInWithEmailAndPassword(
//           email: email, password: password);
//     } catch (e) {
//       rethrow;
//     }
//   }

  

//   // Call this method in main before runApp to ensure Firebase initializes and loads the user session
//   Future<void> loadSession() async {
//     await _firebaseAuth.authStateChanges().first;
//   }

//   @override
//   void dispose() {
//     _currentAuthedUserSubscription.cancel();
//     super.dispose();
//   }
// }