import 'package:flutter/material.dart';
import 'package:uas_prakpemrogramanmobile/core/theme/app_colors.dart';
import 'package:uas_prakpemrogramanmobile/screens/home/home_screen.dart';
import 'package:uas_prakpemrogramanmobile/screens/cart/cart_screen.dart';
import 'package:uas_prakpemrogramanmobile/screens/order/order_history_screen.dart';
import 'package:uas_prakpemrogramanmobile/screens/profile/customer_profile_screen.dart';

class CustomerMainNavigationScreen extends StatefulWidget {
  const CustomerMainNavigationScreen({super.key});

  @override
  State<CustomerMainNavigationScreen> createState() => _CustomerMainNavigationScreenState();
}

class _CustomerMainNavigationScreenState extends State<CustomerMainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const OrderHistoryScreen(),
    const CustomerProfileScreen(),
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
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
