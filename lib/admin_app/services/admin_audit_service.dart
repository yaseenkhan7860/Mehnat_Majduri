import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AdminAuditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Log an admin action for auditing purposes
  Future<void> logAdminAction(
    String actionType, 
    Map<String, dynamic> details, {
    String? targetUserId,
    String? notes,
  }) async {
    try {
      final admin = _auth.currentUser;
      if (admin == null) {
        throw Exception('No authenticated admin user found');
      }
      
      // Get device info
      String deviceInfo = '';
      try {
        deviceInfo = Platform.operatingSystem + ' ' + Platform.operatingSystemVersion;
      } catch (e) {
        // Web platform or error getting device info
        deviceInfo = 'Unknown device';
      }
      
      // Create the audit log entry
      await _firestore.collection('admin_logs').add({
        'adminUid': admin.uid,
        'adminEmail': admin.email,
        'actionType': actionType,
        'details': details,
        'targetUserId': targetUserId,
        'notes': notes,
        'timestamp': FieldValue.serverTimestamp(),
        'deviceInfo': deviceInfo,
      });
      
      debugPrint('Admin action logged: $actionType');
    } catch (e) {
      debugPrint('Error logging admin action: $e');
      // Don't throw - we don't want logging failures to break functionality
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
} 