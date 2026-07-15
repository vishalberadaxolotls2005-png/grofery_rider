import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/utils/widgets/custom_card.dart';
import '../../../../utils/widgets/custom_text.dart';

class ExpandableSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(

      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomText(
                      text: title,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
          // Content
          if (isExpanded) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ],
        ],
      ),
    );
  }
}
