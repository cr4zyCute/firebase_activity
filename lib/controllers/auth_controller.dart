import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Sign-in failed: ${e.message}');
      return null;
    }
  }

  // Sign up with email and password
  // Future<User?> signUp(String email, String password) async {
  //   try {
  //     UserCredential userCredential = await _auth
  //         .createUserWithEmailAndPassword(email: email, password: password);
  //     return userCredential.user;
  //   } on FirebaseAuthException catch (e) {
  //     print('Sign-up failed: ${e.message}');
  //     return null;x`x`
  //   }
  // }
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        print(' New user UID: ${userCredential.user!.uid}');

        final newUser = UserModel(
          id: userCredential.user!.uid, 
          email: email,
          timestamp: Timestamp.now(),
        );

        await addUserToFirestore(newUser);
        return userCredential.user;
      }
      return null;
    } catch (e) {
      print(' Sign-up error: $e');
      return null;
    }
  }

  // Add user data to Firestore
  // Future<void> addUserToFirestore(UserModel user) async {
  //   try {
  //     await _firestore.collection('users').add(user.toMap());
  //     print('User added to Firestore');
  //   } catch (e) {
  //     print('Failed to add user: $e');
  //   }
  // }
  // Add user data to Firestore with UID as document ID
  // Add user data to Firestore
Future<void> addUserToFirestore(UserModel user) async {
    try {
      print('📝 Attempting to write user to Firestore:');
      print('   - UID: ${user.id}');
      print('   - Email: ${user.email}');

      await _firestore.collection('users').doc(user.id).set(user.toMap());

      // Verify the write completed
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.id).get();
      print('✅ Firestore document verified: ${doc.exists}');
    } catch (e) {
      print('❌ Firestore write failed: $e');
      rethrow;
    }
  }

  // Fetch user data from Firestore
  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .orderBy('timestamp', descending: true) // Optional: sort by timestamp
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            print("🔥 Fetched user: ${doc.id} - ${doc.data()}");
            return UserModel.fromFirestore(doc);
          }).toList();
        });
  }
}
