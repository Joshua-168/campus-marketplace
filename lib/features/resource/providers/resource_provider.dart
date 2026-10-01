import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../../data/repositories/resource_repository_impl.dart';
import '../../../domain/entities/resource_entity.dart';
import '../../../domain/repositories/resource_repository.dart';

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  return ResourceRepositoryImpl(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

/// Real-time All Resources Stream Provider
final allResourcesStreamProvider = StreamProvider<List<ResourceEntity>>((ref) {
  return ref.watch(resourceRepositoryProvider).streamResources();
});

/// Real-time Resources Stream filtered by Category
final resourcesByCategoryStreamProvider =
    StreamProvider.family<List<ResourceEntity>, ResourceCategory?>((ref, category) {
  return ref
      .watch(resourceRepositoryProvider)
      .streamResources(category: category);
});

/// Single Resource Detail Stream Provider
final resourceDetailStreamProvider =
    StreamProvider.family<ResourceEntity?, String>((ref, id) {
  return ref.watch(resourceRepositoryProvider).streamResourceById(id);
});

/// User Personal Listings Provider
final userListingsFutureProvider =
    FutureProvider.family<List<ResourceEntity>, String>((ref, userId) async {
  final result =
      await ref.watch(resourceRepositoryProvider).getUserResources(userId);
  return result.fold(
    onSuccess: (data) => data,
    onFailure: (failure) => throw Exception(failure.message),
  );
});
