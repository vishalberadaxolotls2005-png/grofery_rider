import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repo/home_stats_repo.dart';
import 'home_stats_event.dart';
import 'home_stats_state.dart';

class HomeStatsBloc extends Bloc<HomeStatsEvent, HomeStatsState> {
  final HomeStatsRepo _homeStatsRepo;

  HomeStatsBloc(this._homeStatsRepo) : super(HomeStatsInitial()) {
    on<FetchHomeStats>(_onFetchHomeStats);
    on<RefreshHomeStats>(_onRefreshHomeStats);
  }

  Future<void> _onFetchHomeStats(
    FetchHomeStats event,
    Emitter<HomeStatsState> emit,
  ) async {
    try {
      emit(HomeStatsLoading());
      
      final response = await _homeStatsRepo.getHomeStats();
      
      if (response.success) {
        emit(HomeStatsLoaded(response));
      } else {
        emit(HomeStatsError(response.message));
      }
    } catch (e) {
      emit(HomeStatsError(e.toString()));
    }
  }

  Future<void> _onRefreshHomeStats(
    RefreshHomeStats event,
    Emitter<HomeStatsState> emit,
  ) async {
    try {
      emit(HomeStatsLoading());
      
      final response = await _homeStatsRepo.getHomeStats();
      
      if (response.success) {
        emit(HomeStatsLoaded(response));
      } else {
        emit(HomeStatsError(response.message));
      }
    } catch (e) {
      emit(HomeStatsError(e.toString()));
    }
  }
} 
