// Simple base class for use cases
abstract class BaseUseCase<Type, Params> {
  Future<Type> call(Params params);
}

// No parameters class
class NoParams {
  const NoParams();
}