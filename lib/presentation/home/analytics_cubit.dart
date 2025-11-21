import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/analytics_model.dart';
import '../../data/services/analytics_service.dart';
import '../../locator.dart';

abstract class AnalyticsState {}
class AnalyticsInitial extends AnalyticsState {}
class AnalyticsLoading extends AnalyticsState {}
class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsModel analytics;
  AnalyticsLoaded(this.analytics);
}
class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
}

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final _analyticsService = sl<AnalyticsService>();

  AnalyticsCubit() : super(AnalyticsInitial());

  Future<void> loadMetrics(String storeId) async {
    emit(AnalyticsLoading());
    try {
      final data = await _analyticsService.getMonthlyAnalytics(storeId);
      emit(AnalyticsLoaded(data));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}