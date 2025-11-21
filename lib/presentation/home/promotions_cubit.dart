import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/data/models/promotion_model.dart';
import 'package:suefery_partner/locator.dart';

import '../../data/enums/promotion_type.dart';
import '../../data/enums/promotions_status.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/logging_service.dart';
import '../../data/services/promo_service.dart';

class PromoState extends Equatable {
  final PromotionsStatus status;
  final List<Promotion> promotions;
  final String errorMessage;
  final bool isLoading;
  final String error;

  const PromoState({
    this.status = PromotionsStatus.initial,
    this.promotions = const [],
    this.errorMessage = '',
    this.isLoading = false,
    this.error=''
  });

  PromoState copyWith({
    PromotionsStatus? status,
    List<Promotion>? promotions,
    String? errorMessage,
    bool? isLoading,
    String? error,
  }) {
    return PromoState(
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [status, promotions, errorMessage,isLoading,error];
}

class PromoCubit extends Cubit<PromoState> {

  final AuthService _authService = sl<AuthService>();
  final _promoSrvice = sl<PromoService>();
  StreamSubscription? _promotionsSubscription;
  String? _currentStoreId;
  final _log = LoggerRepo('PromotionsCubit');
  PromoCubit() : super(PromoState());
  
  
  void fetchPromo(String storeId) {
    _currentStoreId = storeId;
    _log.i('Fetching inventory for store $storeId');
    _promotionsSubscription?.cancel();
    emit(state.copyWith(isLoading: true));
    _promotionsSubscription?.cancel();
    _promotionsSubscription = _promoSrvice.getPromoStream(storeId).listen(
      (promos) {
        _log.i('fetched for store ${promos.length} promos');
        emit(state.copyWith(promotions: promos, isLoading: false, error: ''));
      },
      onError: (e) => emit(state.copyWith(error: e.toString(), isLoading: false)),
    );
  }

  Future<void> addPromo(
    {
      required String id, 
      required String title, 
      required String description,
      required PromotionType  type, 
      required double value, 
      required DateTime startDate,
      required DateTime endDate,
      required bool isActive 
    }) async {
    if (_currentStoreId == null) return;
    try {

      await _promoSrvice.addPromo(
        Promotion (
        id: '', 
        storeId: _authService.currentFirebaseUser!.uid, 
        title: title, 
        description:description, 
        type: type, 
        value: value, 
        startDate: DateTime.now(), 
        endDate: endDate, 
        isActive  : true 
        )
      );
      // No need to emit, stream will update
    } catch (e) {
      emit(state.copyWith(error:  e.toString()));
    }
  }

  Future<void> updatePromo(
    String id, 
    String title, 
    String description,
    PromotionType  type, 
    double value, 
    DateTime startDate,
    DateTime endDate,
    bool isActive 
    ) async {
    if (_currentStoreId == null) return;
    try {

      await _promoSrvice.updatePromo(
        Promotion(
        id: id, 
        storeId: _authService.currentFirebaseUser!.uid, 
        title: title, 
        description:description, 
        type: type, 
        value: value, 
        startDate: startDate, 
        endDate: endDate, 
        isActive  : isActive 
        )
      );
    } catch (e) {
      emit(state.copyWith(error:  e.toString()));
    }
  }
  
  Future<void> toggleAvailability(String promoId, bool isAvailable) async {
    try {
      await _promoSrvice.updatePromoAvailability(promoId, isAvailable);
    } catch (e) {
      emit(state.copyWith(error:  e.toString()));
    }
  }

  Future<void> deletePromo(String productId) async {
    try {
      await _promoSrvice.removePromo(productId);
    } catch (e) {
      emit(state.copyWith(error:  e.toString()));
    }
  }

  @override
  Future<void> close() {
    _promotionsSubscription?.cancel();
    return super.close();
  }
}