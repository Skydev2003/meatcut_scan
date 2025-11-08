import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'samples_screen.dart';
import 'stats_screen.dart';
import 'model_management_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<IconData> _iconList = [
    Icons.home,
    Icons.dataset,
    Icons.analytics,
    Icons.settings,
  ];

  final List<String> _titleList = ['หน้าหลัก', 'ข้อมูล', 'สถิติ', 'จัดการ'];

  final List<Widget> _screens = const [
    HomeScreen(),
    SamplesScreen(),
    StatsScreen(),
    ModelManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/camera');
        },
        backgroundColor: AppTheme.primaryColor,
        elevation: 8,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.camera_alt, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? AppTheme.primaryColor : AppTheme.textMuted;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_iconList[index], size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                _titleList[index],
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        },
        activeIndex: _currentIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 20,
        rightCornerRadius: 20,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppTheme.darkCard,
        splashColor: AppTheme.primaryColor.withOpacity(0.2),
        splashSpeedInMilliseconds: 300,
        shadow: BoxShadow(
          color: AppTheme.primaryColor.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ),
    );
  }
}
