abstract class WithdrawalEvent {}

class CreateWithdrawal extends WithdrawalEvent {
  final double amount;
  final String note;

  CreateWithdrawal({required this.amount, required this.note});
}

class FetchWithdrawals extends WithdrawalEvent {}
class LoadMoreWithdrawals extends WithdrawalEvent {}

class FetchWithdrawalById extends WithdrawalEvent {
  final int id;

  FetchWithdrawalById({required this.id});
}
