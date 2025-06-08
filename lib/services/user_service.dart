// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new user
  Future<User?> registerUser(UserModel user) async {
    try {
      print('Starting user registration process...');
      
      // Sign out any existing user first
      if (_auth.currentUser != null) {
        await _auth.signOut();
        print('Signed out existing user before registration');
      }

      print('Creating new user with email: ${user.email}');
      // Create user with email and password
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      if (credential.user != null) {
        print('User created successfully in Firebase Auth');
        // Add user data to Firestore
        try {
          await _firestore.collection('users').doc(credential.user!.uid).set({
            'firstName': user.firstName,
            'lastName': user.lastName,
            'email': user.email,
            'created_at': FieldValue.serverTimestamp(),
          });
          print('User data added to Firestore successfully');
        } catch (e) {
          print('Error adding user data to Firestore: $e');
          // If Firestore fails, delete the auth user
          await credential.user?.delete();
          throw e;
        }

        return credential.user;
      }
      print('Failed to create user - no user returned from Firebase Auth');
      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error during registration: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during user registration: $e');
      return null;
    }
  }

  // Sign in a user
  Future<User?> signInUser(String email, String password) async {
    try {
      print('Starting user sign in process...');
      
      // Sign out any existing user first
      if (_auth.currentUser != null) {
        await _auth.signOut();
        print('Signed out existing user before sign in');
      }

      print('Attempting to sign in user with email: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        print('User authenticated successfully in Firebase Auth');
        // Verify user exists in Firestore
        try {
          final userDoc = await _firestore
              .collection('users')
              .doc(credential.user!.uid)
              .get();

          if (!userDoc.exists) {
            print('User document not found in Firestore');
            await _auth.signOut();
            return null;
          }

          print('User document found in Firestore');
          return credential.user;
        } catch (e) {
          print('Error checking Firestore document: $e');
          await _auth.signOut();
          return null;
        }
      }
      print('Sign in failed - no user returned from Firebase Auth');
      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error during sign in: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during user sign in: $e');
      return null;
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      print('Checking if email exists: $email');
      final result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      
      final exists = result.docs.isNotEmpty;
      print('Email exists check result: $exists');
      return exists;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }
}
