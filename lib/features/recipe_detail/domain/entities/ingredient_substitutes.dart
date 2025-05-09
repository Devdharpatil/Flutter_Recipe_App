import 'package:equatable/equatable.dart';

class IngredientSubstitutes extends Equatable {
  final String ingredient;
  final List<String> substitutes;
  final String message;

  const IngredientSubstitutes({
    required this.ingredient,
    required this.substitutes,
    required this.message,
  });

  @override
  List<Object?> get props => [ingredient, substitutes, message];
} 