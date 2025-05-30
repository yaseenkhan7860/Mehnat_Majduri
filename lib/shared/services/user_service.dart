import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Set user role
  Future<void> setUserRole(User user, String role, {String? displayName}) async {
    try {
      // Store the user role in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName ?? user.displayName,
        'photoURL': user.photoURL,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // In a real app, you would call a Firebase Cloud Function to set custom claims
      debugPrint('User role set to $role for ${user.uid}');
    } catch (e) {
      debugPrint('Error setting user role: $e');
      rethrow;
    }
  }
  
  // Get user role
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }
} 