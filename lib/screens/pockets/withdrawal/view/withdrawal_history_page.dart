import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grofery_rider/utils/widgets/empty_state_widget.dart';

import '../../../../config/colors.dart';
import '../../../../utils/widgets/custom_scaffold.dart';
import '../../../../utils/widgets/custom_appbar_without_navbar.dart';
import '../../../../utils/widgets/loading_widget.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/withdrawal_bloc.dart';
import '../bloc/withdrawal_event.dart';
import '../bloc/withdrawal_state.dart';
import '../model/withdrawal_model.dart';
import '../repo/withdrawal_repo.dart';
import '../view/widgets/withdrawal_card.dart';
import '../view/widgets/withdrawal_empty_state.dart';
import '../view/widgets/create_withdrawal_sheet.dart';

class WithdrawalHistoryPage extends StatefulWidget {
  const WithdrawalHistoryPage({super.key});

  @override
  State<WithdrawalHistoryPage> createState() => _WithdrawalHistoryPageState();
}

class WithdrawalHistoryPageWithBloc extends StatelessWidget {
  const WithdrawalHistoryPageWithBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WithdrawalBloc(WithdrawalRepo()),
      child: const WithdrawalHistoryPage(),
    );
  }
}

class _WithdrawalHistoryPageState extends State<WithdrawalHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Fetch withdrawals when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WithdrawalBloc>().add(FetchWithdrawals());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<WithdrawalBloc>().add(LoadMoreWithdrawals());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _showCreateWithdrawalDialog() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const CreateWithdrawalSheet(),
    );

    if (result == true && mounted) {
      context.read<WithdrawalBloc>().add(FetchWithdrawals());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBarWithoutNavbar(
        title: AppLocalizations.of(context)!.withdrawalHistory,
      ),
      body: BlocConsumer<WithdrawalBloc, WithdrawalState>(
        listener: (context, state) {
          if (state is WithdrawalError) {
            // Handle error if needed
          }
        },
        builder: (context, state) {
          if (state is WithdrawalLoading) {
            return const Center(child: LoadingWidget());
          } else if (state is WithdrawalSuccess) {
            return _buildWithdrawalsList(state.response, state.isFetchingMore);
          } else if (state is WithdrawalError) {
            return ErrorStateWidget(
              onRetry: (){
                context.read<WithdrawalBloc>().add(FetchWithdrawals());
              }
            );
            // return WithdrawalErrorState(errorMessage: state.errorMessage);
          } else {
            return const WithdrawalEmptyState();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'request-withdrawal',
        onPressed: _showCreateWithdrawalDialog,
        backgroundColor: AppColors.primaryColor,
        child:Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildWithdrawalsList(WithdrawalResponse response, bool isFetchingMore) {
    if (response.data?.data.isEmpty ?? true) {
      return const WithdrawalEmptyState();
    }

    final withdrawals = response.data?.data ?? [];

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: withdrawals.length + (isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == withdrawals.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: const Center(child: LoadingWidget()),
          );
        }
        final withdrawal = withdrawals[index];
        return WithdrawalCard(withdrawal: withdrawal);
      },
    );
  }
}
