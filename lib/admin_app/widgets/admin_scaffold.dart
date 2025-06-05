import 'package:flutter/material.dart';
import 'package:astro/admin_app/services/admin_audit_service.dart';
import 'package:astro/shared/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminScaffold extends StatefulWidget {
  final Widget body;
  final int currentIndex;
  final String? title;

  const AdminScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    this.title,
  });

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final auditService = AdminAuditService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(_getTitle()),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: Icon(Icons.person, color: Colors.purple.shade800),
                      ),
                      title: const Text('Admin Profile'),
                      subtitle: Text(
                        authService.currentUser?.email ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(ScreenUtil().radius(20)),
              bottomRight: Radius.circular(ScreenUtil().radius(20)),
            ),
            child: Drawer(
              width: ScreenUtil().setWidth(270), // Reduced width
              elevation: 10,
              child: Column(
                children: [
                  Container(
                    height: ScreenUtil().setHeight(120),
                    width: double.infinity,
                    color: Colors.deepPurple.shade800,
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20)),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: ScreenUtil().setWidth(60),
                          height: ScreenUtil().setHeight(60),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/admin/admin_app.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: ScreenUtil().setHeight(8)),
                        Text(
                          'Admin Panel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildDrawerItem(
                            icon: Icons.dashboard,
                            title: 'Dashboard',
                            index: 0,
                            route: '/admin_home',
                          ),
                          const Divider(height: 1),
                          
                          // User Management Section
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              ScreenUtil().setWidth(16), 
                              ScreenUtil().setHeight(16), 
                              ScreenUtil().setWidth(16), 
                              ScreenUtil().setHeight(8)
                            ),
                            child: Text(
                              'USER MANAGEMENT',
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(12),
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildDrawerItem(
                            icon: Icons.people,
                            title: 'Manage Customers',
                            index: 1,
                            route: '/manage_customers',
                          ),
                          _buildDrawerItem(
                            icon: Icons.school,
                            title: 'Manage Astrologers',
                            index: 2,
                            route: '/manage_astrologers',
                          ),
                          _buildDrawerItem(
                            icon: Icons.admin_panel_settings,
                            title: 'Manage Admins',
                            index: 3,
                            route: '/manage_admins',
                          ),
                          
                          const Divider(height: 1),
                          
                          // Product Management Section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'PRODUCT MANAGEMENT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildDrawerItem(
                            icon: Icons.shopping_bag,
                            title: 'Manage Products',
                            index: 5,
                            route: '/manage_products',
                          ),
                          
                          const Divider(height: 1),
                          
                          // Course Management Section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'COURSE MANAGEMENT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildDrawerItem(
                            icon: Icons.menu_book,
                            title: 'All Courses',
                            index: 6,
                            route: '/all_courses',
                          ),
                          _buildDrawerItem(
                            icon: Icons.edit_note,
                            title: 'Manage Courses',
                            index: 7,
                            route: '/manage_courses',
                          ),
                          
                          const Divider(height: 1),
                          
                          // Home Page Management Section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'HOME PAGE MANAGEMENT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildDrawerItem(
                            icon: Icons.newspaper,
                            title: 'News',
                            index: 8,
                            route: '/news',
                          ),
                          _buildDrawerItem(
                            icon: Icons.view_carousel,
                            title: 'Banner',
                            index: 9,
                            route: '/banner',
                          ),
                          _buildDrawerItem(
                            icon: Icons.star_rate,
                            title: 'Kundali Review',
                            index: 10,
                            route: '/kundali_review',
                          ),
                          _buildDrawerItem(
                            icon: Icons.auto_graph,
                            title: 'Horoscope Review',
                            index: 11,
                            route: '/horoscope_review',
                          ),
                          
                          const Divider(height: 1),
                          
                          // Live Management Section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'LIVE MANAGEMENT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildDrawerItem(
                            icon: Icons.live_tv,
                            title: 'Live Sessions',
                            index: 12,
                            route: '/live_sessions',
                          ),
                          _buildDrawerItem(
                            icon: Icons.videocam,
                            title: 'Manage Recordings',
                            index: 13,
                            route: '/manage_recordings',
                          ),
                          
                          const Divider(height: 1),
                          
                          // Earnings Section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'EARNINGS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildDrawerItem(
                            icon: Icons.shopping_cart,
                            title: 'Product Sales',
                            index: 14,
                            route: '/product_sales',
                          ),
                          _buildDrawerItem(
                            icon: Icons.card_membership,
                            title: 'Subscription Sales',
                            index: 15,
                            route: '/subscription_sales',
                          ),
                          _buildDrawerItem(
                            icon: Icons.bar_chart,
                            title: 'Total Stats',
                            index: 16,
                            route: '/total_stats',
                          ),
                          
                          const Divider(height: 1),
                          
                          // Community Section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'COMMUNITY',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildDrawerItem(
                            icon: Icons.groups,
                            title: 'Community Room',
                            index: 17,
                            route: '/community_room',
                          ),
                          _buildDrawerItem(
                            icon: Icons.chat,
                            title: 'User Chats',
                            index: 18,
                            route: '/user_chats',
                          ),
                          
                          const Divider(height: 1),
                          
                          // System Section
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'SYSTEM',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildDrawerItem(
                            icon: Icons.settings,
                            title: 'Settings',
                            index: 4,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.logout, color: Colors.red, size: 22),
                      title: const Text('Logout', style: TextStyle(color: Colors.red)),
                      minLeadingWidth: 20,
                      onTap: () async {
                        await authService.signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.body,
          ),
        );
      },
    );
  }
  
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    String? route,
    VoidCallback? onTap,
  }) {
    final bool isSelected = widget.currentIndex == index;
    
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16), vertical: 0),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      leading: Icon(
        icon,
        size: ScreenUtil().setSp(20),
        color: isSelected ? Colors.purple.shade700 : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(13),
          color: isSelected ? Colors.purple.shade700 : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      minLeadingWidth: ScreenUtil().setWidth(18),
      tileColor: isSelected ? Colors.purple.shade50 : null,
      onTap: onTap ?? () {
        Navigator.pop(context);
        if (route != null) {
          Navigator.pushReplacementNamed(context, route);
          // Log navigation action
          auditService.logAdminAction(
            'navigate',
            {'screen': title},
          );
        }
      },
    );
  }
  
  String _getTitle() {
    switch (widget.currentIndex) {
      case 0:
        return 'Admin Dashboard';
      case 1:
        return 'Manage Customers';
      case 2:
        return 'Manage Astrologers';
      case 3:
        return 'Manage Admins';
      case 4:
        return 'Settings';
      default:
        return widget.title ?? 'Admin Panel';
    }
  }
} 