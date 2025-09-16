// Base class for use cases following Clean Architecture
abstract class BaseUseCase<Type, Params> {
  Future<Type> call(Params params);
}

class NoParams {
  const NoParams();
}