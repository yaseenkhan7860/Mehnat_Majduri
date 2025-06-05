import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AdminAuditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Log an admin action for auditing purposes
  Future<void> logAdminAction(String action, Map<String, dynamic> details) async {
    try {
      final adminUser = _auth.currentUser;
      if (adminUser == null) {
        debugPrint('AdminAuditService: No admin user logged in, cannot log action: $action');
        return; // Return silently instead of throwing exception
      }

      // Check if the user has a valid token
      final idToken = await adminUser.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        debugPrint('AdminAuditService: Invalid token for user ${adminUser.uid}');
        return;
      }

      debugPrint('AdminAuditService: Logging action $action for admin ${adminUser.email}');

      await _firestore.collection('admin_logs').add({
        'action': action,
        'details': details,
        'adminId': adminUser.uid,
        'adminEmail': adminUser.email,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'admin_action',
      });
      
      debugPrint('AdminAuditService: Successfully logged action $action');
    } catch (e) {
      debugPrint('AdminAuditService: Error logging admin action: $e');
    }
  }
  
  /// Get admin logs for the current admin user
  Stream<QuerySnapshot> getMyAdminLogs() {
    final admin = _auth.currentUser;
    if (admin == null) {
      throw Exception('No authenticated admin user found');
    }
    
    return _firestore
        .collection('admin_logs')
        .where('adminUid', isEqualTo: admin.uid)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
  }
  
  /// Get all admin logs (for super admins)
  Stream<QuerySnapshot> getAllAdminLogs() {
    return _firestore
        .collection('admin_logs')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
  }
  
  /// Get admin logs for a specific action type
  Stream<QuerySnapshot> getAdminLogsByActionType(String actionType) {
    return _firestore
        .collection('admin_logs')
        .where('actionType', isEqualTo: actionType)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }
  
  /// Get admin logs for actions on a specific user
  Stream<QuerySnapshot> getAdminLogsByTargetUser(String targetUserId) {
    return _firestore
        .collection('admin_logs')
        .where('targetUserId', isEqualTo: targetUserId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  Stream<QuerySnapshot> getAdminLogs({
    String? adminId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _firestore
        .collection('admin_logs')
        .orderBy('timestamp', descending: true);

    if (adminId != null) {
      query = query.where('adminId', isEqualTo: adminId);
    }

    if (action != null) {
      query = query.where('action', isEqualTo: action);
    }

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: endDate);
    }

    return query.snapshots();
  }

  Future<void> clearOldLogs(int daysToKeep) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      final snapshot = await _firestore
          .collection('admin_logs')
          .where('timestamp', isLessThan: cutoffDate)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing old logs: $e');
    }
  }

  Future<Map<String, dynamic>> getAdminStats(String adminId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final todayLogs = await _firestore
          .collection('admin_logs')
          .where('adminId', isEqualTo: adminId)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .count()
          .get();

      final totalLogs = await _firestore
          .collection('admin_logs')
          .where('adminId', isEqualTo: adminId)
          .count()
          .get();

      return {
        'todayActions': todayLogs.count ?? 0,
        'totalActions': totalLogs.count ?? 0,
      };
    } catch (e) {
      print('Error getting admin stats: $e');
      return {
        'todayActions': 0,
        'totalActions': 0,
      };
    }
  }
} 