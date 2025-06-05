import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:astro/shared/services/auth_service.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService;
  
  AdminService(this._authService);
  
  // Check if current user is admin
  Future<bool> get isAdmin async {
    if (_auth.currentUser?.email != 'astroapp.admin@astroapp.com') return false;
    
    try {
      final adminDoc = await _firestore.collection('admins').doc(_auth.currentUser!.uid).get();
      return adminDoc.exists;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }
  
  // Secure method to create an instructor account
  Future<void> createInstructorAccount(String email, String password, String name) async {
    if (!(await isAdmin)) {
      throw Exception('Only administrators can create instructor accounts');
    }
    
    try {
      // First create the user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Then set user data in Firestore with instructor role in the instructors collection
      await _firestore.collection('instructors').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'displayName': name,
        'role': 'instructor',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser!.uid,
      });
      
      // Send email verification
      await userCredential.user?.sendEmailVerification();
      
      debugPrint('Instructor account created successfully for $email');
    } catch (e) {
      debugPrint('Error creating instructor account: $e');
      rethrow;
    }
  }
  
  // Get all users with pagination
  Future<List<Map<String, dynamic>>> getUsers({
    int limit = 20, 
    DocumentSnapshot? lastDocument,
    String? userType, // 'admin', 'instructor', or 'user'
  }) async {
    if (!(await isAdmin)) {
      throw Exception('Only administrators can access user data');
    }
    
    try {
      // Determine which collection to query based on userType
      String collection = 'users'; // Default to regular users
      if (userType == 'admin') {
        collection = 'admins';
      } else if (userType == 'instructor') {
        collection = 'instructors';
      }
      
      Query query = _firestore.collection(collection)
        .orderBy('createdAt', descending: true)
        .limit(limit);
      
      // Apply pagination if lastDocument is provided
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      final QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
          'userType': userType ?? 'user',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting users: $e');
      rethrow;
    }
  }
  
  // Update user role (this will move the user between collections)
  Future<void> updateUserRole(String userId, String newRole) async {
    if (!(await isAdmin)) {
      throw Exception('Only administrators can update user roles');
    }
    
    if (!['admin', 'instructor', 'user'].contains(newRole)) {
      throw Exception('Invalid role: $newRole');
    }
    
    // Extra security check for admin role
    if (newRole == 'admin') {
      throw Exception('Admin role can only be assigned manually by a Firebase administrator');
    }
    
    try {
      // First, determine which collection the user is currently in
      String currentCollection = '';
      DocumentSnapshot? userDoc;
      
      // Check each collection for the user
      final adminDoc = await _firestore.collection('admins').doc(userId).get();
      final instructorDoc = await _firestore.collection('instructors').doc(userId).get();
      final userDoc2 = await _firestore.collection('users').doc(userId).get();
      
      if (adminDoc.exists) {
        currentCollection = 'admins';
        userDoc = adminDoc;
      } else if (instructorDoc.exists) {
        currentCollection = 'instructors';
        userDoc = instructorDoc;
      } else if (userDoc2.exists) {
        currentCollection = 'users';
        userDoc = userDoc2;
      } else {
        throw Exception('User not found in any collection');
      }
      
      // Determine target collection based on new role
      String targetCollection = '';
      if (newRole == 'instructor') {
        targetCollection = 'instructors';
      } else if (newRole == 'user') {
        targetCollection = 'users';
      }
      
      // If the role change requires moving between collections
      if (currentCollection != targetCollection) {
        // Copy user data to the new collection
        await _firestore.collection(targetCollection).doc(userId).set({
          ...userDoc!.data() as Map<String, dynamic>,
          'role': newRole,
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': _auth.currentUser!.uid,
        });
        
        // Delete from the old collection
        await _firestore.collection(currentCollection).doc(userId).delete();
      } else {
        // Just update the role in the current collection
        await _firestore.collection(currentCollection).doc(userId).update({
          'role': newRole,
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': _auth.currentUser!.uid,
        });
      }
      
      debugPrint('User role updated successfully for $userId to $newRole');
    } catch (e) {
      debugPrint('Error updating user role: $e');
      rethrow;
    }
  }
  
  // Delete user account
  Future<void> deleteUserAccount(String userId) async {
    if (!(await isAdmin)) {
      throw Exception('Only administrators can delete user accounts');
    }
    
    try {
      // Check each collection for the user
      bool deleted = false;
      
      // Try to delete from admins collection
      final adminDoc = await _firestore.collection('admins').doc(userId).get();
      if (adminDoc.exists) {
        throw Exception('Admin accounts cannot be deleted through this interface');
      }
      
      // Try to delete from instructors collection
      final instructorDoc = await _firestore.collection('instructors').doc(userId).get();
      if (instructorDoc.exists) {
        await _firestore.collection('instructors').doc(userId).delete();
        deleted = true;
      }
      
      // Try to delete from users collection
      if (!deleted) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          await _firestore.collection('users').doc(userId).delete();
          deleted = true;
        }
      }
      
      if (!deleted) {
        throw Exception('User not found in any collection');
      }
      
      // Then delete the user from Firebase Auth (requires Firebase Admin SDK on backend)
      // This would typically be done via a Cloud Function
      debugPrint('User data deleted from Firestore. Auth deletion requires a Cloud Function.');
      
    } catch (e) {
      debugPrint('Error deleting user account: $e');
      rethrow;
    }
  }
  
  // Get app statistics for admin dashboard
  Future<Map<String, dynamic>> getAppStatistics() async {
    if (!(await isAdmin)) {
      throw Exception('Only administrators can access app statistics');
    }
    
    try {
      // Get user counts by collection
      final adminCount = await _firestore.collection('admins')
          .count()
          .get()
          .then((snapshot) => snapshot.count ?? 0);
          
      final instructorCount = await _firestore.collection('instructors')
          .count()
          .get()
          .then((snapshot) => snapshot.count ?? 0);
          
      final userCount = await _firestore.collection('users')
          .count()
          .get()
          .then((snapshot) => snapshot.count ?? 0);
      
      final userStats = {
        'totalUsers': adminCount + instructorCount + userCount,
        'admins': adminCount,
        'instructors': instructorCount,
        'regularUsers': userCount,
      };
      
      // Get course count
      final courseCount = await _firestore.collection('courses')
          .count()
          .get()
          .then((snapshot) => snapshot.count);
      
      // Get product count
      final productCount = await _firestore.collection('products')
          .count()
          .get()
          .then((snapshot) => snapshot.count);
      
      // Get order count and total revenue
      final orderStats = await _firestore.collection('orders')
          .get()
          .then((snapshot) {
            int orderCount = snapshot.docs.length;
            double totalRevenue = 0;
            
            for (var doc in snapshot.docs) {
              totalRevenue += (doc.data()['amount'] ?? 0).toDouble();
            }
            
            return {
              'orderCount': orderCount,
              'totalRevenue': totalRevenue,
            };
          });
      
      return {
        'users': userStats,
        'courseCount': courseCount,
        'productCount': productCount,
        'orders': orderStats,
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting app statistics: $e');
      rethrow;
    }
  }
  
  // Update app settings
  Future<void> updateAppSettings(Map<String, dynamic> settings) async {
    if (!(await isAdmin)) {
      throw Exception('Only administrators can update app settings');
    }
    
    try {
      await _firestore.collection('settings').doc('appSettings').set({
        ...settings,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser!.uid,
      }, SetOptions(merge: true));
      
      debugPrint('App settings updated successfully');
    } catch (e) {
      debugPrint('Error updating app settings: $e');
      rethrow;
    }
  }
  
  // Get app settings
  Future<Map<String, dynamic>> getAppSettings() async {
    if (!(await isAdmin)) {
      throw Exception('Only administrators can access app settings');
    }
    
    try {
      final doc = await _firestore.collection('settings').doc('appSettings').get();
      return doc.exists ? doc.data() as Map<String, dynamic> : {};
    } catch (e) {
      debugPrint('Error getting app settings: $e');
      rethrow;
    }
  }
} 