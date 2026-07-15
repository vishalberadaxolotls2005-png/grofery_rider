import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:grofery_rider/config/theme_bloc.dart';
import 'package:grofery_rider/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import 'package:grofery_rider/l10n/app_localizations.dart';
import 'package:grofery_rider/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_bloc.dart';
import 'package:grofery_rider/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_state.dart';
import '../../../config/colors.dart';
import '../bloc/profile_bloc/profile_bloc.dart';
import '../bloc/profile_bloc/profile_event.dart';
import '../bloc/profile_bloc/profile_state.dart';
import '../model/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBarWithoutNavbar(
        title: AppLocalizations.of(context)!.profile,
        showRefreshButton: true,
        onRefreshPressed: () {
          context.read<ProfileBloc>().add(const LoadProfile());
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, themeState) {
                final isDarkTheme = themeState.currentTheme == 'dark';
                return BlocBuilder<
                  DeliveryBoyStatusBloc,
                  DeliveryBoyStatusState
                >(
                  builder: (context, statusState) {
                    final isOnline = statusState.isOnline;
                    return BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, profileState) {
                        if (profileState is ProfileLoaded) {
                          final profile = profileState.profile;
                          final profilePictureUrl = profile.user?.profileImage;

                          return CustomCard(
                            padding: EdgeInsets.all(10.w),
                            child: Row(
                              children: [
                                // Profile Avatar with Initials Fallback
                                CircleAvatar(
                                  radius: 40.r,
                                  backgroundColor: _getAvatarBackgroundColor(
                                    context,
                                    profile,
                                  ),
                                  child:
                                      profilePictureUrl != null &&
                                              profilePictureUrl.isNotEmpty
                                          ? ClipOval(
                                            child: Image.network(
                                              profilePictureUrl,
                                              width: 80.r,
                                              height: 80.r,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                      ),
                                                );
                                              },
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return _buildInitialsAvatar(
                                                  context,
                                                  profile,
                                                );
                                              },
                                            ),
                                          )
                                          : _buildInitialsAvatar(
                                            context,
                                            profile,
                                          ),
                                ),

                                SizedBox(width: 16.w),

                                // Text content (name + status badge)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomText(
                                        text:
                                            profile.deliveryBoy?.fullName ??
                                            profile.user?.name ??
                                            AppLocalizations.of(
                                              context,
                                            )!.deliveryPartner,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),

                                      SizedBox(height: 8.h),

                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 14.w,
                                          vertical: 5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              profile.deliveryBoy != null
                                                  ? (isOnline
                                                          ? Colors.green
                                                          : Colors.orange)
                                                      .withValues(
                                                        alpha:
                                                            isDarkTheme
                                                                ? 0.3
                                                                : 0.15,
                                                      )
                                                  : Colors.grey.withValues(
                                                    alpha:
                                                        isDarkTheme
                                                            ? 0.3
                                                            : 0.15,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                        ),
                                        child: CustomText(
                                          text:
                                              isOnline
                                                  ? AppLocalizations.of(
                                                    context,
                                                  )!.active
                                                  : AppLocalizations.of(
                                                    context,
                                                  )!.inactive,
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              profile.deliveryBoy != null
                                                  ? (isOnline
                                                      ? (isDarkTheme
                                                          ? Colors.green[300]
                                                          : Colors.green[700])
                                                      : (isDarkTheme
                                                          ? Colors.orange[300]
                                                          : Colors.orange[700]))
                                                  : (isDarkTheme
                                                      ? Colors.grey[400]
                                                      : Colors.grey[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (profileState is ProfileError) {
                          return Container();
                        } else {
                          // Show loading state
                          return CustomCard(
                            padding: EdgeInsets.all(10.w),
                            child: Row(
                              children: [
                                // Profile Avatar (left side)
                                CircleAvatar(
                                  radius: 40.r,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  child: Icon(
                                    Icons.person,
                                    size: 40.sp,
                                    color:
                                        isDarkTheme
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.onSurface
                                            : AppColors.primaryColor,
                                  ),
                                ),

                                SizedBox(
                                  width: 16.w,
                                ), // Horizontal spacing instead of vertical
                                // Text content (name + status badge)
                                Expanded(
                                  // Takes remaining space and prevents overflow
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize:
                                        MainAxisSize
                                            .min, // Keeps column compact
                                    children: [
                                      CustomText(
                                        text: '',
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),

                                      SizedBox(height: 8.h),

                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withValues(
                                            alpha: 0.6,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20.r,
                                          ),
                                        ),
                                        child: CustomText(
                                          text: 'active',
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
            SizedBox(height: 24.h),

            // Profile Options
            _buildProfileOption(
              icon: Icons.person_outline,
              title: AppLocalizations.of(context)!.personalInformation,
              subtitle: AppLocalizations.of(context)!.updatePersonalDetails,
              onTap: () => context.push('/personal-info'),
            ),
            _buildProfileOption(
              icon: Icons.phone_outlined,
              title: AppLocalizations.of(context)!.contactInformation,
              subtitle: AppLocalizations.of(context)!.updatePhoneAndEmail,
              onTap: () => context.push('/contact-info'),
            ),
            _buildProfileOption(
              icon: Icons.directions_car_outlined,
              title: AppLocalizations.of(context)!.vehicleInformation,
              subtitle: AppLocalizations.of(context)!.updateVehicleDetails,
              onTap: () => context.push('/vehicle-info'),
            ),
            // _buildProfileOption(
            //   icon: Icons.location_on_outlined,
            //   title: AppLocalizations.of(context)!.deliveryZones,
            //   subtitle: AppLocalizations.of(context)!.manageDeliveryAreas,
            //   onTap: () => context.push('/delivery-zone'),
            // ),
            _buildProfileOption(
              icon: Icons.verified_user_outlined,
              title: AppLocalizations.of(context)!.verificationStatus,
              subtitle: AppLocalizations.of(context)!.checkVerificationStatus,
              onTap: () => context.push('/verification-status'),
            ),
            _buildProfileOption(
              icon: Icons.document_scanner_outlined,
              title: AppLocalizations.of(context)!.documents,
              subtitle: AppLocalizations.of(context)!.uploadAndManageDocuments,
              onTap: () => context.push('/documents'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context, ProfileModel profile) {
    final String name =
        profile.deliveryBoy?.fullName ??
        AppLocalizations.of(context)!.deliveryPartner;

    final String initials = _getInitials(name);

    return Text(
      initials,
      style: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "??";

    List<String> nameParts = name.trim().split(RegExp(r'\s+'));
    String initials = "";

    if (nameParts.isNotEmpty) {
      initials += nameParts[0][0].toUpperCase();
    }
    if (nameParts.length > 1) {
      initials += nameParts.last[0].toUpperCase();
    }

    return initials;
  }

  Color _getAvatarBackgroundColor(BuildContext context, ProfileModel profile) {
    // You can make this dynamic based on name hash for consistent colors
    final bool hasName =
        profile.deliveryBoy?.fullName != null &&
        profile.deliveryBoy!.fullName!.isNotEmpty;

    if (!hasName) {
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    }

    // Optional: Generate color from name (consistent per user)
    final String name = profile.deliveryBoy!.fullName!;
    final int hash = name.hashCode;
    final List<Color> avatarColors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];
    return avatarColors[hash.abs() % avatarColors.length];
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: CustomCard(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: AppColors.primaryColor, size: 18.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: title,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      SizedBox(height: 4.h),
                      CustomText(
                        text: subtitle,
                        fontSize: 12.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
