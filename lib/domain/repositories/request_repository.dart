import '../../core/utils/result.dart';
import '../entities/request_entity.dart';

/// Abstract Domain Contract for Request system operations.
abstract class RequestRepository {
  Future<Result<String>> createRequest(RequestEntity request);

  Stream<List<RequestEntity>> streamBorrowerRequests(String borrowerId);

  Stream<List<RequestEntity>> streamOwnerRequests(String ownerId);

  Future<Result<void>> updateRequestStatus({
    required String requestId,
    required RequestStatus newStatus,
  });
}
