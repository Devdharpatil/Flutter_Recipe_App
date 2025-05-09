import 'package:equatable/equatable.dart';

class Favorite extends Equatable {
  final int id;
  final int recipeId;
  final String userId;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      recipeId: json['recipe_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, recipeId, userId, createdAt];
} 