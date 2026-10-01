import 'package:rxdart/rxdart.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/request_repository.dart';
import '../models/request_model.dart';
import '../services/firestore_service.dart';

class RequestRepositoryImpl implements RequestRepository {
  final FirestoreService firestoreService;
  static const String _collectionName = 'Requests';

  // In-memory local requests store for fallback execution
  final BehaviorSubject<List<RequestEntity>> _localRequestsSubject =
      BehaviorSubject<List<RequestEntity>>.seeded([]);

  RequestRepositoryImpl({required this.firestoreService});

  @override
  Future<Result<String>> createRequest(RequestEntity request) async {
    final current = List<RequestEntity>.from(_localRequestsSubject.value);
    current.insert(0, request);
    _localRequestsSubject.add(current);

    if (firestoreService.firestore == null) {
      return Result.success(request.id);
    }

    try {
      final model = RequestModel.fromEntity(request);
      await firestoreService.setDocument(
        collection: _collectionName,
        docId: request.id,
        data: model.toFirestore(),
      );
      return Result.success(request.id);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<RequestEntity>> streamBorrowerRequests(String borrowerId) {
    if (firestoreService.firestore == null) {
      return _localRequestsSubject.stream.map((list) {
        return list.where((item) => item.borrowerId == borrowerId).toList();
      });
    }

    return firestoreService.streamCollection(
      collection: _collectionName,
      queryBuilder: (query) => query.where('borrowerId', isEqualTo: borrowerId),
    ).map((snapshot) {
      return snapshot.docs
          .map((doc) => RequestModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }

  @override
  Stream<List<RequestEntity>> streamOwnerRequests(String ownerId) {
    if (firestoreService.firestore == null) {
      return _localRequestsSubject.stream.map((list) {
        return list.where((item) => item.ownerId == ownerId).toList();
      });
    }

    return firestoreService.streamCollection(
      collection: _collectionName,
      queryBuilder: (query) => query.where('ownerId', isEqualTo: ownerId),
    ).map((snapshot) {
      return snapshot.docs
          .map((doc) => RequestModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }

  @override
  Future<Result<void>> updateRequestStatus({
    required String requestId,
    required RequestStatus newStatus,
  }) async {
    final current = List<RequestEntity>.from(_localRequestsSubject.value);
    final index = current.indexWhere((i) => i.id == requestId);
    if (index != -1) {
      current[index] = current[index].copyWith(status: newStatus, updatedAt: DateTime.now());
      _localRequestsSubject.add(current);
    }

    if (firestoreService.firestore == null) {
      return const Result.success(null);
    }

    try {
      await firestoreService.updateDocument(
        collection: _collectionName,
        docId: requestId,
        data: {
          'status': newStatus.displayName,
          'updatedAt': DateTime.now(),
        },
      );
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
