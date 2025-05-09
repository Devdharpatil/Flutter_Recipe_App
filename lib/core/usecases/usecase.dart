import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// A base abstract class defining the contract for all use cases
/// 
/// [Type] is the expected return type (success case)
/// [Params] is the input parameters type (often a sealed class or case object)
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// For use cases that don't require parameters
class NoParams {
  const NoParams();
} 