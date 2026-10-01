import '../../core/utils/result.dart';
import '../entities/resource_entity.dart';

/// Abstract Domain Contract for Firestore Resource operations.
abstract class ResourceRepository {
  Future<Result<List<ResourceEntity>>> getResources({
    ResourceCategory? category,
    ResourceAvailability? availability,
    int limit = 20,
  });

  Stream<List<ResourceEntity>> streamResources({
    ResourceCategory? category,
    ResourceAvailability? availability,
  });

  Future<Result<ResourceEntity>> getResourceById(String id);

  Stream<ResourceEntity?> streamResourceById(String id);

  Future<Result<String>> createResource(ResourceEntity resource);

  Future<Result<void>> updateResource(ResourceEntity resource);

  Future<Result<void>> deleteResource(String id);

  Future<Result<List<ResourceEntity>>> getUserResources(String userId);

  Future<Result<List<ResourceEntity>>> searchResources(String query);
}
