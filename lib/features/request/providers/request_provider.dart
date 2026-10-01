import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../../data/repositories/request_repository_impl.dart';
import '../../../domain/entities/request_entity.dart';
import '../../../domain/repositories/request_repository.dart';

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepositoryImpl(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

final sentRequestsStreamProvider =
    StreamProvider.family<List<RequestEntity>, String>((ref, borrowerId) {
  return ref.watch(requestRepositoryProvider).streamBorrowerRequests(borrowerId);
});

final receivedRequestsStreamProvider =
    StreamProvider.family<List<RequestEntity>, String>((ref, ownerId) {
  return ref.watch(requestRepositoryProvider).streamOwnerRequests(ownerId);
});

class RequestState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const RequestState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  RequestState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return RequestState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class RequestNotifier extends StateNotifier<RequestState> {
  final RequestRepository repository;

  RequestNotifier({required this.repository}) : super(const RequestState());

  Future<bool> sendRequest(RequestEntity request) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    final result = await repository.createRequest(request);

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

  Future<bool> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    final result = await repository.updateRequestStatus(
      requestId: requestId,
      newStatus: status,
    );

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

final requestNotifierProvider =
    StateNotifierProvider<RequestNotifier, RequestState>((ref) {
  return RequestNotifier(
    repository: ref.watch(requestRepositoryProvider),
  );
});
