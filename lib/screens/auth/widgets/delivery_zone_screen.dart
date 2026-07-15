import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/widgets/custom_button.dart';
import '../../../utils/widgets/custom_text.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';

import '../bloc/delivery_zone_bloc/delivery_zone_bloc.dart';
import '../bloc/delivery_zone_bloc/delivery_zone_event.dart';
import '../bloc/delivery_zone_bloc/delivery_zone_state.dart';

class DeliveryZoneScreen extends StatefulWidget {
  const DeliveryZoneScreen({super.key});

  @override
  State<DeliveryZoneScreen> createState() => _DeliveryZoneScreenState();
}

class _DeliveryZoneScreenState extends State<DeliveryZoneScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Trigger initial fetch
    context.read<DeliveryZoneBloc>().add(const FetchDeliveryZones());
    // Add scroll listener for load settings
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Trigger load settings when 80% of the list is scrolled
      context.read<DeliveryZoneBloc>().add(const LoadMoreDeliveryZones());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: CustomText(text: AppLocalizations.of(context)!.deliveryZones),
      ),
      body: BlocBuilder<DeliveryZoneBloc, DeliveryZoneState>(
        builder: (context, state) {
          if (state is DeliveryZoneInitial) {
            return Center(
              child: CustomText(text: AppLocalizations.of(context)!.pleaseWait),
            );
          } else if (state is DeliveryZoneLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DeliveryZoneLoaded) {
            if (state.deliveryZones.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 24),
                      CustomText(
                        text:
                            AppLocalizations.of(
                              context,
                            )?.noDeliveryZonesAvailable ??
                            "No delivery zones available",
                        textAlign: TextAlign.center,

                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 12),
                      CustomText(
                        text:
                            AppLocalizations.of(
                              context,
                            )?.deliveryZonesNotConfigured ??
                            "Delivery zones have not been configured yet.",
                        textAlign: TextAlign.center,

                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        textSize: 15.sp,
                        text: AppLocalizations.of(context)!.retry,
                        onPressed: () {
                          context.read<DeliveryZoneBloc>().add(
                            const FetchDeliveryZones(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.only(top: 20),
              controller: _scrollController,
              itemCount:
                  state.hasReachedMax
                      ? state.deliveryZones.length
                      : state.deliveryZones.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.deliveryZones.length) {
                  // Show loading indicator at the bottom when loading settings
                  return const Center(child: CircularProgressIndicator());
                }
                final zone = state.deliveryZones[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.2),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.location_on_rounded),
                    title: CustomText(text: zone.name ?? ""),
                    trailing:
                        state.selectedZone?.id == zone.id
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                    onTap: () {
                      context.read<DeliveryZoneBloc>().add(
                        SelectDeliveryZone(selectedZone: zone),
                      );

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        context.pop(zone);
                      });
                    },
                  ),
                );
              },
            );
          } else if (state is DeliveryZoneError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(text: 'Error: ${state.message}'),
                  const SizedBox(height: 16),
                  CustomButton(
                    textSize: 15.sp,
                    text: AppLocalizations.of(context)!.retry,
                    onPressed: () {
                      context.read<DeliveryZoneBloc>().add(
                        const FetchDeliveryZones(),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
