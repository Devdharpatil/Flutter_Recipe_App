part of 'onboarding_cubit.dart';

class OnboardingState extends Equatable {
  final int currentPage;
  final int previousPage;
  final int totalPages;
  final List<String> selectedDiets;
  final List<String> selectedCookingStyles;

  const OnboardingState({
    required this.currentPage,
    this.previousPage = 0,
    required this.totalPages,
    this.selectedDiets = const [],
    this.selectedCookingStyles = const [],
  });

  OnboardingState copyWith({
    int? currentPage,
    int? previousPage,
    int? totalPages,
    List<String>? selectedDiets,
    List<String>? selectedCookingStyles,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      previousPage: previousPage ?? this.previousPage,
      totalPages: totalPages ?? this.totalPages,
      selectedDiets: selectedDiets ?? this.selectedDiets,
      selectedCookingStyles: selectedCookingStyles ?? this.selectedCookingStyles,
    );
  }

  @override
  List<Object?> get props => [
        currentPage,
        previousPage,
        totalPages,
        selectedDiets,
        selectedCookingStyles,
      ];
} 