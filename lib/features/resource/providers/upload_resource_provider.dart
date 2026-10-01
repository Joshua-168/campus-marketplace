import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/resource_entity.dart';
import '../../../domain/repositories/resource_repository.dart';
import 'resource_provider.dart';

class UploadResourceState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? uploadedImageUrl;

  const UploadResourceState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.uploadedImageUrl,
  });

  UploadResourceState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? uploadedImageUrl,
  }) {
    return UploadResourceState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
    );
  }
}

class UploadResourceNotifier extends StateNotifier<UploadResourceState> {
  final ResourceRepository repository;

  UploadResourceNotifier({required this.repository})
      : super(const UploadResourceState());

  void setUploadedImageUrl(String url) {
    state = state.copyWith(uploadedImageUrl: url);
  }

  Future<bool> createListing({
    required String title,
    required String description,
    required ResourceCategory category,
    required ResourceCondition condition,
    required double price,
    required double depositAmount,
    required String ownerId,
    required String ownerName,
    required String ownerEmail,
    required String campusName,
    required String imageUrl,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    final newResource = ResourceEntity(
      id: const Uuid().v4(),
      title: title.trim(),
      description: description.trim(),
      category: category,
      condition: condition,
      imageUrl: imageUrl.trim(),
      availability: ResourceAvailability.available,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      price: price,
      depositAmount: depositAmount,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      campusName: campusName,
    );

    final result = await repository.createResource(newResource);

    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> updateListing(ResourceEntity updatedResource) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    final result = await repository.updateResource(updatedResource);

    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
    );
  }
}

final uploadResourceNotifierProvider =
    StateNotifierProvider<UploadResourceNotifier, UploadResourceState>((ref) {
  return UploadResourceNotifier(
    repository: ref.watch(resourceRepositoryProvider),
  );
});

