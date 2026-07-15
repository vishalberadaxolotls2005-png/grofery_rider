import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/services.dart';
import 'package:grofery_rider/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:grofery_rider/utils/widgets/custom_text.dart';
import 'package:grofery_rider/utils/widgets/custom_button.dart';
import 'package:grofery_rider/utils/widgets/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../../../config/colors.dart';
import '../../../../utils/widgets/custom_scaffold.dart';
import '../../../../utils/widgets/toast_message.dart';

class DocumentViewerPage extends StatefulWidget {
  final String documentUrl;
  final String documentTitle;

  const DocumentViewerPage({
    super.key,
    required this.documentUrl,
    required this.documentTitle,
  });

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkDocumentUrl();
  }

  void _checkDocumentUrl() {
    // Check if the URL is valid
    try {
      Uri.parse(widget.documentUrl);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Invalid document URL';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBarWithoutNavbar(
        title: widget.documentTitle,
        showRefreshButton: false,
        showThemeToggle: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return _buildDocumentInfo();
  }

  Widget _buildDocumentInfo() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Header
          _buildDocumentHeader(isDarkTheme),
          SizedBox(height: 24.h),

          // Document Details
          _buildSectionTitle('Document Information'),
          SizedBox(height: 16.h),

          _buildInfoCard(
            title: 'Document Type',
            value: _getDocumentType(widget.documentUrl),
            icon: Icons.description_outlined,
            color: Colors.blue,
          ),
          SizedBox(height: 16.h),

          _buildInfoCard(
            title: 'Document URL',
            value: widget.documentUrl,
            icon: Icons.link_outlined,
            color: Colors.green,
            isUrl: true,
          ),
          SizedBox(height: 24.h),

          // Actions
          _buildSectionTitle('Actions'),
          SizedBox(height: 16.h),

          _buildActionButton(
            icon: Icons.open_in_new,
            title: 'Open in Browser',
            subtitle: 'View document in external browser',
            onTap: _openInBrowser,
            color: AppColors.primaryColor,
          ),
          SizedBox(height: 16.h),

          _buildActionButton(
            icon: Icons.download_outlined,
            title: 'Download Document',
            subtitle: 'Save document to your device',
            onTap: _downloadDocument,
            color: Colors.green,
          ),
          SizedBox(height: 16.h),

          _buildActionButton(
            icon: Icons.share_outlined,
            title: 'Share Document',
            subtitle: 'Share document with others',
            onTap: _shareDocument,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentHeader(bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDarkTheme
                  ? [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.8),
                  ]
                  : [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withValues(alpha: 0.8),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Document Icon (Left)
          CircleAvatar(
            radius: 40.r,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Icon(
              _getDocumentIcon(widget.documentUrl),
              size: 30.sp,
              color:
                  isDarkTheme
                      ? Theme.of(context).colorScheme.onSurface
                      : AppColors.primaryColor,
            ),
          ),
          SizedBox(width: 16.w),

          // Title + Status Badge (Right)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Document Title
                CustomText(
                  text: widget.documentTitle,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color:
                      isDarkTheme
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.white,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 8.h),

                // Availability Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: CustomText(
                    text: 'AVAILABLE',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        isDarkTheme
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Optional: Add a trailing download/view icon
          // Icon(Icons.arrow_forward_ios, size: 20.sp, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return CustomText(
      text: title,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isUrl = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: isUrl ? 'Tap to copy' : value,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      isUrl
                          ? AppColors.primaryColor
                          : Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ),
          if (isUrl)
            IconButton(
              icon: Icon(Icons.copy_outlined, color: AppColors.primaryColor),
              onPressed: () => _copyToClipboard(value),
              tooltip: 'Copy URL',
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, color: color, size: 24.sp),
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

  String _getDocumentType(String url) {
    final extension = url.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'PDF Document';
      case 'jpg':
      case 'jpeg':
        return 'JPEG Image';
      case 'png':
        return 'PNG Image';
      case 'doc':
        return 'Word Document';
      case 'docx':
        return 'Word Document';
      default:
        return 'Document';
    }
  }

  IconData _getDocumentIcon(String url) {
    final extension = url.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Future<void> _openInBrowser() async {
    final Uri url = Uri.parse(widget.documentUrl);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ToastManager.show(
            context: context,
            message: 'Could not launch browser for this URL',
            type: ToastType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ToastManager.show(
          context: context,
          message: 'Error opening browser: $e',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _downloadDocument() async {
    try {
      final dio = Dio();
      final directory = await getApplicationDocumentsDirectory();
      final fileName = widget.documentUrl.split('/').last;
      final savePath = '${directory.path}/$fileName';

      if (mounted) {
        ToastManager.show(
          context: context,
          message: 'Starting download...',
          type: ToastType.info,
        );
      }

      await dio.download(widget.documentUrl, savePath);

      if (mounted) {
        ToastManager.show(
          context: context,
          message: 'Document saved to $savePath',
          type: ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        ToastManager.show(
          context: context,
          message: 'Download failed: $e',
          type: ToastType.error,
        );
      }
    }
  }

  void _shareDocument() {
    Share.share(
      'Check out this document: ${widget.documentTitle}\n${widget.documentUrl}',
      subject: widget.documentTitle,
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (mounted) {
        ToastManager.show(
          context: context,
          message: 'URL copied to clipboard',
          type: ToastType.success,
        );
      }
    });
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Colors.red.withValues(alpha: 0.6),
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: 'Failed to Load Document',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: _errorMessage,
            fontSize: 14.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          CustomButton(
            text: 'Go Back',
            onPressed: () => Navigator.pop(context),
            backgroundColor: AppColors.primaryColor,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
