import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Set user role
  Future<void> setUserRole(User user, String role, {String? displayName}) async {
    try {
      // Validate the role
      if (!['admin', 'instructor', 'user'].contains(role)) {
        throw Exception('Invalid role: $role. Must be admin, instructor, or user.');
      }
      
      // For admin role, store in the admins collection
      if (role == 'admin') {
        await _firestore.collection('admins').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': displayName ?? user.displayName ?? 'Admin User',
          'photoURL': user.photoURL,
          'isActive': true,
          'isAdmin': true, // Explicit flag for security checks
          'role': 'admin', // Explicit role field
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('Admin user created/updated in admins collection: ${user.uid}');
        return;
      }
      
      // For instructor role, store in the instructors collection only
      if (role == 'instructor') {
        await _firestore.collection('instructors').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': displayName ?? user.displayName ?? 'Instructor',
          'photoURL': user.photoURL,
          'isActive': true,
          'role': 'instructor', // Explicit role field
          'isInstructor': true, // Explicit flag for security checks
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('Instructor user created/updated in instructors collection: ${user.uid}');
        return;
      }
      
      // For regular users, store in the users collection
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName ?? user.displayName,
        'photoURL': user.photoURL,
        'role': 'user', // Explicit role field
        'isActive': true,
        'isUser': true, // Explicit flag for security checks
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('User role set to $role for ${user.uid}');
    } catch (e) {
      debugPrint('Error setting user role: $e');
      rethrow;
    }
  }
  
  // Get user role
  Future<String?> getUserRole(String uid) async {
    try {
      debugPrint('Getting role for user: $uid');
      
      // Check admins collection first
      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (adminDoc.exists) {
        debugPrint('User is an admin');
        return 'admin';
      }
      
      // Check instructors collection
      final instructorDoc = await _firestore.collection('instructors').doc(uid).get();
      if (instructorDoc.exists) {
        debugPrint('User is an instructor (from instructors collection)');
        return 'instructor';
      }
      
      // Check users collection
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final role = userDoc.data()?['role'] as String?;
        debugPrint('User found in users collection with role: $role');
        return role ?? 'user';
      }
      
      debugPrint('User not found in any collection');
      return null;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }
  
  // Get user data based on role
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      // First determine the role
      final role = await getUserRole(uid);
      if (role == null) return null;
      
      // Get data from the appropriate collection
      String collection;
      switch (role) {
        case 'admin':
          collection = 'admins';
          break;
        case 'instructor':
          collection = 'instructors';
          break;
        case 'user':
          collection = 'users';
          break;
        default:
          return null;
      }
      
      final doc = await _firestore.collection(collection).doc(uid).get();
      if (!doc.exists) return null;
      
      // Update last login
      await _firestore.collection(collection).doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      return doc.data();
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }
} 