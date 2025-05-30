import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:astro/admin_app/services/admin_audit_service.dart';
import 'package:intl/intl.dart';

class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  State<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> {
  final AdminAuditService _auditService = AdminAuditService();
  String _filterType = 'all'; // 'all', 'my', 'action', 'user'
  String? _selectedActionType;
  String? _selectedUserId;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Audit Logs'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterType = value;
                // Reset filters when changing filter type
                if (value != 'action') _selectedActionType = null;
                if (value != 'user') _selectedUserId = null;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Logs'),
              ),
              const PopupMenuItem(
                value: 'my',
                child: Text('My Actions'),
              ),
              const PopupMenuItem(
                value: 'action',
                child: Text('Filter by Action'),
              ),
              const PopupMenuItem(
                value: 'user',
                child: Text('Filter by User'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _buildLogsList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterBar() {
    if (_filterType == 'action') {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Action Type',
            border: OutlineInputBorder(),
          ),
          value: _selectedActionType,
          items: const [
            DropdownMenuItem(value: 'create_instructor', child: Text('Create Instructor')),
            DropdownMenuItem(value: 'set_user_role', child: Text('Change User Role')),
            DropdownMenuItem(value: 'delete_user', child: Text('Delete User')),
            DropdownMenuItem(value: 'login', child: Text('Admin Login')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedActionType = value;
            });
          },
        ),
      );
    } else if (_filterType == 'user') {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'User ID',
            border: OutlineInputBorder(),
            hintText: 'Enter user ID to filter logs',
          ),
          onSubmitted: (value) {
            setState(() {
              _selectedUserId = value;
            });
          },
        ),
      );
    } else {
      return const SizedBox(height: 8);
    }
  }
  
  Widget _buildLogsList() {
    Stream<QuerySnapshot> logsStream;
    
    switch (_filterType) {
      case 'my':
        logsStream = _auditService.getMyAdminLogs();
        break;
      case 'action':
        if (_selectedActionType != null) {
          logsStream = _auditService.getAdminLogsByActionType(_selectedActionType!);
        } else {
          return const Center(child: Text('Select an action type'));
        }
        break;
      case 'user':
        if (_selectedUserId != null) {
          logsStream = _auditService.getAdminLogsByTargetUser(_selectedUserId!);
        } else {
          return const Center(child: Text('Enter a user ID'));
        }
        break;
      case 'all':
      default:
        logsStream = _auditService.getAllAdminLogs();
        break;
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: logsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No logs found'));
        }
        
        final logs = snapshot.data!.docs;
        
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index].data() as Map<String, dynamic>;
            final timestamp = log['timestamp'] as Timestamp?;
            final formattedDate = timestamp != null
                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate())
                : 'Unknown time';
                
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ExpansionTile(
                title: Text(
                  log['actionType'] ?? 'Unknown Action',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('$formattedDate by ${log['adminEmail'] ?? 'Unknown admin'}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (log['targetUserId'] != null) ...[
                          Text('Target User: ${log['targetUserId']}'),
                          const SizedBox(height: 8),
                        ],
                        if (log['notes'] != null) ...[
                          Text('Notes: ${log['notes']}'),
                          const SizedBox(height: 8),
                        ],
                        const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        _buildDetailsView(log['details']),
                        const SizedBox(height: 8),
                        Text('Device: ${log['deviceInfo'] ?? 'Unknown device'}'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildDetailsView(dynamic details) {
    if (details == null) {
      return const Text('No details available');
    }
    
    if (details is Map<String, dynamic>) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: details.entries.map((entry) {
          return Text('${entry.key}: ${entry.value}');
        }).toList(),
      );
    }
    
    return Text(details.toString());
  }
} 