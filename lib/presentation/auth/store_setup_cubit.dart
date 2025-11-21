import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreSetupState extends Equatable {
  final int currentStep;
  final String storeName;
  final String bio;
  final String website;
  final String address;
  final String city;
  final double lat;
  final double lng;
  final List<String> tags;
  final String? errorMessage;

  const StoreSetupState({
    this.currentStep = 0,
    this.storeName = '',
    this.bio = '',
    this.website = '',
    this.address = '',
    this.city = 'Beni Suef', // Default
    this.lat = 29.0744, // Default Lat
    this.lng = 31.0979, // Default Lng
    this.tags = const [],
    this.errorMessage,
  });

  StoreSetupState copyWith({
    int? currentStep,
    String? storeName,
    String? bio,
    String? website,
    String? address,
    String? city,
    double? lat,
    double? lng,
    List<String>? tags,
    String? errorMessage,
  }) {
    return StoreSetupState(
      currentStep: currentStep ?? this.currentStep,
      storeName: storeName ?? this.storeName,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      tags: tags ?? this.tags,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        storeName,
        bio,
        website,
        address,
        city,
        lat,
        lng,
        tags,
        errorMessage,
      ];
}

class StoreSetupCubit extends Cubit<StoreSetupState> {
  StoreSetupCubit() : super(const StoreSetupState());

  // --- Field Updates ---
  void storeNameChanged(String value) => emit(state.copyWith(storeName: value));
  void bioChanged(String value) => emit(state.copyWith(bio: value));
  void websiteChanged(String value) => emit(state.copyWith(website: value));
  void addressChanged(String value) => emit(state.copyWith(address: value));
  void cityChanged(String value) => emit(state.copyWith(city: value));
  
  void latChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) emit(state.copyWith(lat: parsed));
  }

  void lngChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) emit(state.copyWith(lng: parsed));
  }

  // --- Tag Logic ---
  void addTag(String tag) {
    if (tag.trim().isNotEmpty) {
      final updatedTags = List<String>.from(state.tags)..add(tag.trim());
      emit(state.copyWith(tags: updatedTags));
    }
  }

  void removeTag(String tag) {
    final updatedTags = List<String>.from(state.tags)..remove(tag);
    emit(state.copyWith(tags: updatedTags));
  }

  // --- Navigation & Validation ---
  bool nextStep() {
    if (state.currentStep == 0) {
      if (state.storeName.isEmpty) {
        emit(state.copyWith(errorMessage: 'Store Name is required'));
        return false;
      }
    } else if (state.currentStep == 1) {
      if (state.address.isEmpty || state.city.isEmpty) {
        emit(state.copyWith(errorMessage: 'Address and City are required'));
        return false;
      }
    }

    if (state.currentStep < 2) {
      emit(state.copyWith(currentStep: state.currentStep + 1, errorMessage: null));
      return false; // Not finished yet
    }
    
    return true; // Ready to submit
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1, errorMessage: null));
    }
  }

  bool validateSubmission() {
    if (state.tags.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please add at least one tag'));
      return false;
    }
    return true;
  }
}