import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/screens/admin/admin_dashboard_screen.dart';
import 'package:uas_prakpemrogramanmobile/screens/admin/top_products_screen.dart';
import 'package:uas_prakpemrogramanmobile/screens/admin/manage_orders_screen.dart';
import 'package:uas_prakpemrogramanmobile/screens/admin/admin_profile_screen.dart';

class AdminMainNavigationScreen extends StatefulWidget {
  const AdminMainNavigationScreen({super.key});

  @override
  State<AdminMainNavigationScreen> createState() => _AdminMainNavigationScreenState();
}

class _AdminMainNavigationScreenState extends State<AdminMainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const TopProductsScreen(),
    const ManageOrdersScreen(),
    const AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.card,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.secondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: 'Top Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
