import 'package:equatable/equatable.dart';

abstract class HomeStatsEvent extends Equatable {
  const HomeStatsEvent();

  @override
  List<Object?> get props => [];
}

class FetchHomeStats extends HomeStatsEvent {
  const FetchHomeStats();
}

class RefreshHomeStats extends HomeStatsEvent {
  const RefreshHomeStats();
} 
