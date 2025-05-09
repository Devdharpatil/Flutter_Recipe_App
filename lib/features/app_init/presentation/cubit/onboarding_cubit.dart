import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final PageController pageController;
  final SharedPreferences _sharedPreferences;
  
  OnboardingCubit({
    required this.pageController,
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences,
       super(const OnboardingState(currentPage: 0, totalPages: 4));

  void goToNextPage() {
    if (state.currentPage < state.totalPages - 1) {
      final nextPage = state.currentPage + 1;
      final prevPage = state.currentPage;
      pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      emit(state.copyWith(currentPage: nextPage, previousPage: prevPage));
    }
  }

  void goToPreviousPage() {
    if (state.currentPage > 0) {
      final previousPage = state.currentPage - 1;
      final prevPage = state.currentPage;
      pageController.animateToPage(
        previousPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      emit(state.copyWith(currentPage: previousPage, previousPage: prevPage));
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < state.totalPages) {
      final prevPage = state.currentPage;
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      emit(state.copyWith(currentPage: page, previousPage: prevPage));
    }
  }

  void onPageChanged(int page) {
    final prevPage = state.currentPage;
    emit(state.copyWith(currentPage: page, previousPage: prevPage));
  }

  // Handle dietary preferences in the last (4th) onboarding screen
  void toggleDietaryPreference(String diet) {
    final currentSelections = List<String>.from(state.selectedDiets);
    if (currentSelections.contains(diet)) {
      currentSelections.remove(diet);
    } else {
      currentSelections.add(diet);
    }
    emit(state.copyWith(selectedDiets: currentSelections));
  }

  void toggleCookingStyle(String style) {
    final currentSelections = List<String>.from(state.selectedCookingStyles);
    if (currentSelections.contains(style)) {
      currentSelections.remove(style);
    } else {
      currentSelections.add(style);
    }
    emit(state.copyWith(selectedCookingStyles: currentSelections));
  }

  // Complete onboarding and save preferences
  Future<void> completeOnboarding({bool savePreferences = true}) async {
    // Save temporary preferences if requested
    if (savePreferences) {
      await _sharedPreferences.setStringList('dietary_preferences', state.selectedDiets);
      await _sharedPreferences.setStringList('cooking_styles', state.selectedCookingStyles);
    }
  }

  Future<void> skipOnboarding() async {
    // Discard any selected preferences and mark onboarding as completed
    emit(state.copyWith(
      selectedDiets: const [],
      selectedCookingStyles: const [],
    ));
  }
} 