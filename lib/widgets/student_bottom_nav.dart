import 'package:flutter/material.dart';

class StudentBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const StudentBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF3B82F6),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: currentIndex.clamp(0, 4),
      selectedIconTheme: IconThemeData(
        color: (currentIndex < 0 || currentIndex > 4)
            ? Colors.grey
            : const Color(0xFF3B82F6),
      ),
      selectedLabelStyle: TextStyle(
        fontWeight: (currentIndex < 0 || currentIndex > 4)
            ? FontWeight.normal
            : FontWeight.bold,
      ),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.assessment), label: 'Assessment'),
        BottomNavigationBarItem(
            icon: Icon(Icons.location_on), label: 'Find Help'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: 'Appointments'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
      ],
      onTap: (index) {
        // Basic navigation logic, can be expanded later
        // Avoids navigating to the same page
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            // Navigate to Home (Dashboard)
            Navigator.pushNamedAndRemoveUntil(
                context, '/student/dashboard', (route) => false);
            break;
          // Add cases for other pages if direct navigation is needed
        }
      },
    );
  }
}
