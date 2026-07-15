// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:grofery_rider/utils/widgets/custom_scaffold.dart';
// import '../../../../utils/widgets/loading_widget.dart';
// import '../../../../utils/widgets/custom_appbar_without_navbar.dart';
// import '../bloc/withdrawal_bloc.dart';
// import '../bloc/withdrawal_event.dart';
// import '../bloc/withdrawal_state.dart';
// import '../repo/withdrawal_repo.dart';
// import '../model/withdrawal_model.dart';
// import 'widgets/withdrawal_summary_cards.dart';
// import 'widgets/withdrawal_card.dart';
// import 'widgets/create_withdrawal_sheet.dart';
// import 'widgets/withdrawal_empty_state.dart';
// import 'widgets/withdrawal_error_state.dart';
// import '../../../../utils/widgets/toast_message.dart';
// import 'package:grofery_rider/l10n/app_localizations.dart';
// import '../../../../utils/widgets/custom_text.dart';
//
// class WithdrawalPage extends StatefulWidget {
//   const WithdrawalPage({super.key});
//
//   @override
//   State<WithdrawalPage> createState() => _WithdrawalPageState();
// }
//
// class WithdrawalPageWithBloc extends StatelessWidget {
//   const WithdrawalPageWithBloc({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => WithdrawalBloc(WithdrawalRepo()),
//       child: const WithdrawalPage(),
//     );
//   }
// }
//
// class _WithdrawalPageState extends State<WithdrawalPage> {
//   @override
//   void initState() {
//     super.initState();
//     // Fetch withdrawals on page load
//     context.read<WithdrawalBloc>().add(FetchWithdrawals());
//   }
//
//   void _showCreateWithdrawalDialog() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) => const CreateWithdrawalSheet(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return CustomScaffold(
//       appBar: CustomAppBarWithoutNavbar(
//         title: 'My Withdrawals',
//         onRefreshPressed: () {
//           context.read<WithdrawalBloc>().add(FetchWithdrawals());
//         },
//       ),
//       body: BlocConsumer<WithdrawalBloc, WithdrawalState>(
//         listener: (context, state) {
//           if (state is CreateWithdrawalSuccess) {
//             ToastManager.show(
//               context: context,
//               message: 'Withdrawal request submitted successfully!',
//               type: ToastType.success,
//             );
//             context.read<WithdrawalBloc>().add(FetchWithdrawals());
//           } else if (state is WithdrawalError) {
//             ToastManager.show(
//               context: context,
//               message: state.errorMessage,
//               type: ToastType.error,
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is WithdrawalLoading) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(color: theme.colorScheme.primary),
//                   SizedBox(height: 16.h),
//                   CustomText(
//                     text: AppLocalizations.of(context)!.loadingWithdrawals,
//                     fontSize: 16.sp,
//                     color: theme.colorScheme.onSurface.withValues(alpha:0.7),
//                   ),
//                 ],
//               ),
//             );
//           } else if (state is WithdrawalSuccess) {
//             return _buildWithdrawalsList(state.response);
//           } else if (state is WithdrawalError) {
//             return WithdrawalErrorState(errorMessage: state.errorMessage);
//           }
//
//           return const Center(child: LoadingWidget());
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _showCreateWithdrawalDialog,
//         backgroundColor: theme.colorScheme.primary,
//         icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
//         label: CustomText(
//           text: AppLocalizations.of(context)!.requestWithdrawal,
//           fontSize: 16.sp,
//           fontWeight: FontWeight.w600,
//           color: theme.colorScheme.onPrimary,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildWithdrawalsList(WithdrawalResponse response) {
//     if (response.data?.data.isEmpty ?? true) {
//       return const WithdrawalEmptyState();
//     }
//
//     return Column(
//       children: [
//         // Summary Cards
//         WithdrawalSummaryCards(response: response),
//
//         // Withdrawals List
//         Expanded(
//           child: ListView.builder(
//             padding: EdgeInsets.symmetric(horizontal: 16.w),
//             itemCount: response.data?.data.length ?? 0,
//             itemBuilder: (context, index) {
//               final withdrawal = response.data!.data[index];
//               return WithdrawalCard(withdrawal: withdrawal);
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
