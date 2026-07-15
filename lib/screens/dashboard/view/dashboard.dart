import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grofery_rider/config/global.dart';

import 'package:grofery_rider/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_bloc.dart';
import 'package:grofery_rider/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_event.dart';
import 'package:grofery_rider/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_state.dart';
import 'package:grofery_rider/screens/feed_page/view/home_page.dart';
import 'package:grofery_rider/utils/widgets/bottombar.dart';
import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  @override
  void initState() {
    super.initState();
    _initializeStatus();
  }

  Future<void> _initializeStatus() async {
    final status = await Global.getDeliveryBoyStatus() ?? false;
    setState(() {
    });

    if (!mounted) return;

    // Sync the initial status with the bloc (this will also check API status)
    context.read<DeliveryBoyStatusBloc>().add(SyncInitialStatus(status));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeliveryBoyStatusBloc, DeliveryBoyStatusState>(
      listener: (context, state) {

        if (state is DeliveryBoyStatusLoaded) {

          setState(() {
          });

        }
      },
      child: CustomScaffold(
        key: const Key('dashboard_scaffold'),
        body: Builder(
          builder: (context) {

            return _buildDashboardContent();
          },
        ),
        bottomNavigationBar: _buildDashboardBottomNav(),
      ),
    );
  }

  Widget _buildDashboardContent() {
    // Always show the FeedPageWithStatus which contains Available Orders and My Orders tabs
    return const FeedPageWithStatus();
  }

  Widget _buildDashboardBottomNav() {
    // Use the new GoRouter-based BottomNavBar
    return const BottomNavBar(child: FeedPageWithStatus());
  }
}
