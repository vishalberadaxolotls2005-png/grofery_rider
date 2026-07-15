import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/colors.dart';
import 'pockets_page.dart';
import '../../../router/app_routes.dart';

class PocketsPageWrapper extends StatefulWidget {
  const PocketsPageWrapper({super.key});

  @override
  State<PocketsPageWrapper> createState() => _PocketsPageWrapperState();
}

class _PocketsPageWrapperState extends State<PocketsPageWrapper> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PocketsPage(),
      bottomNavigationBar: BottomNavigationBar(
                      items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
              BottomNavigationBarItem(icon: Icon(Icons.g_mobiledata_rounded), label: 'Gigs'),
              BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Pockets'),
              BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
            ],
                      currentIndex: 2, // Pockets tab
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface,
          onTap: (index) {
                  // Define the routes for each tab
      final routes = [
        AppRoutes.feed,
        AppRoutes.gigs,
        AppRoutes.pockets,
        AppRoutes.more,
      ];
            
            if (index < routes.length) {
              context.go(routes[index]);
            }
          },
          elevation: 10,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          type: BottomNavigationBarType.fixed,
        ),
    );
  }
} 
