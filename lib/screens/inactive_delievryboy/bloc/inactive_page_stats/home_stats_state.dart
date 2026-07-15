import 'package:equatable/equatable.dart';

import '../../model/home_stats_model.dart';

abstract class HomeStatsState extends Equatable {
  const HomeStatsState();

  @override
  List<Object?> get props => [];
}

class HomeStatsInitial extends HomeStatsState {}

class HomeStatsLoading extends HomeStatsState {}

class HomeStatsLoaded extends HomeStatsState {
  final HomeStatsResponse response;

  const HomeStatsLoaded(this.response);

  @override
  List<Object?> get props => [response];
}

class HomeStatsError extends HomeStatsState {
  final String message;

  const HomeStatsError(this.message);

  @override
  List<Object?> get props => [message];
} 
