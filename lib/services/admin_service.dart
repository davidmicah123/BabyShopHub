// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _isInitialized = false;

  Future<Map<String, bool>> _checkAdminStatus() async {
    try {
      bool authExists = false;
      bool firestoreExists = false;

      print('Checking admin status...');
      
      // Check Firestore first
      final adminQuery = await _firestore
          .collection('admins')
          .where('email', isEqualTo: 'admin@admin.com')
          .get();
      
      firestoreExists = adminQuery.docs.isNotEmpty;
      print('Firestore admin exists: $firestoreExists');

      // Then check Auth
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: 'admin@admin.com',
          password: 'admin_babyshop',
        );
        
        authExists = credential.user != null;
        print('Auth admin exists: $authExists');
        
        // Always sign out after check
        await _auth.signOut();
      } on FirebaseAuthException catch (e) {
        print('Auth check failed: ${e.code} - ${e.message}');
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          authExists = false;
        } else {
          rethrow;
        }
      }

      return {
        'authExists': authExists,
        'firestoreExists': firestoreExists,
      };
    } catch (e) {
      print('Error checking admin status: $e');
      return {
        'authExists': false,
        'firestoreExists': false,
      };
    }
  }

  Future<void> initializeAdminAccount() async {
    if (_isInitialized) {
      print('Admin initialization already completed');
      return;
    }

    try {
      print('Starting admin initialization...');
      final status = await _checkAdminStatus();
      
      if (!status['authExists']! || !status['firestoreExists']!) {
        print('Need to create or update admin account...');
        
        try {
          UserCredential? credential;
          
          // Handle Auth
          if (!status['authExists']!) {
            print('Creating new auth user...');
            try {
              credential = await _auth.createUserWithEmailAndPassword(
                email: 'admin@admin.com',
                password: 'admin_babyshop',
              );
              print('Auth user created successfully');
            } on FirebaseAuthException catch (e) {
              print('Error creating auth user: ${e.code} - ${e.message}');
              if (e.code == 'email-already-in-use') {
                print('Email already in use, attempting to sign in...');
                credential = await _auth.signInWithEmailAndPassword(
                  email: 'admin@admin.com',
                  password: 'admin_babyshop',
                );
                print('Successfully signed in existing admin');
              } else {
                throw e;
              }
            }
          }

          if (credential?.user != null) {
            print('Creating/updating Firestore document...');
            // Create or update Firestore document
            await _firestore.collection('admins').doc(credential!.user!.uid).set({
              'email': 'admin@admin.com',
              'username': 'Admin',
              'role': 'super_admin',
              'created_at': FieldValue.serverTimestamp(),
              'is_active': true,
              'uid': credential.user!.uid
            });
            print('Firestore document created/updated successfully');
          }
          
          // Always sign out after operations
          if (_auth.currentUser != null) {
            await _auth.signOut();
            print('Signed out after admin setup');
          }
        } catch (e) {
          print('Error in admin creation/update: $e');
          throw e;
        }
      } else {
        print('Admin account already exists and is properly configured');
      }
      
      _isInitialized = true;
      print('Admin initialization completed successfully');
    } catch (e) {
      print('Error in initializeAdminAccount: $e');
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
      throw e;
    }
  }

  Future<Map<String, dynamic>?> signInAdmin(String email, String password) async {
    try {
      print('Attempting admin sign in...');
      
      // Sign out any existing user first
      if (_auth.currentUser != null) {
        await _auth.signOut();
        print('Signed out existing user');
      }

      print('Attempting admin sign in with email: $email');

      if (email != 'admin@admin.com' || password != 'admin_babyshop') {
        print('Invalid credentials provided');
        return null;
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        print('Sign in failed - no user returned');
        return null;
      }

      print('Auth successful, checking Firestore document...');
      final adminDoc = await _firestore
          .collection('admins')
          .doc(credential.user!.uid)
          .get();

      if (!adminDoc.exists || adminDoc.data() == null) {
        print('Admin document not found in Firestore');
        await _auth.signOut();
        return null;
      }

      final adminData = adminDoc.data()!;
      print('Admin sign in successful');
      
      return {
        'user': {
          'uid': credential.user!.uid,
          'email': credential.user!.email ?? 'admin@admin.com',
          'displayName': adminData['username'] ?? 'Admin',
        },
        'adminData': adminData,
      };
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
      rethrow;
    } catch (e) {
      print('Error in signInAdmin: $e');
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
      return null;
    }
  }

  // Update admin status
  Future<bool> updateAdminStatus(String adminId, bool isActive) async {
    try {
      await _firestore.collection('admins').doc(adminId).update({
        'is_active': isActive,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating admin status: $e');
      return false;
    }
  }

  // Get all admins
  Stream<List<Admin>> getAllAdmins() {
    return _firestore.collection('admins').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Admin.fromFirestore(doc)).toList();
    });
  }

  // Delete admin
  Future<bool> deleteAdmin(String adminId) async {
    try {
      DocumentSnapshot adminDoc = await _firestore.collection('admins').doc(adminId).get();

      if (adminDoc.exists) {
        await _firestore.collection('admins').doc(adminId).delete();

        User? user = _auth.currentUser;
        if (user?.uid == adminId) {
          await user?.delete();
        }

        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting admin: $e');
      return false;
    }
  }
}
