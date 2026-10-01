enum RequestStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected'),
  completed('Completed');

  final String displayName;
  const RequestStatus(this.displayName);

  static RequestStatus fromString(String statusStr) {
    return RequestStatus.values.firstWhere(
      (e) => e.displayName.toLowerCase() == statusStr.toLowerCase(),
      orElse: () => RequestStatus.pending,
    );
  }
}

/// Pure Domain Entity representing a borrowing / purchasing request.
class RequestEntity {
  final String id;
  final String resourceId;
  final String resourceTitle;
  final String resourceImageUrl;
  final String borrowerId;
  final String borrowerName;
  final String borrowerEmail;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final RequestStatus status;
  final String notes;
  final int proposedDurationDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RequestEntity({
    required this.id,
    required this.resourceId,
    required this.resourceTitle,
    required this.resourceImageUrl,
    required this.borrowerId,
    required this.borrowerName,
    required this.borrowerEmail,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.status,
    required this.notes,
    required this.proposedDurationDays,
    required this.createdAt,
    required this.updatedAt,
  });

  RequestEntity copyWith({
    String? id,
    String? resourceId,
    String? resourceTitle,
    String? resourceImageUrl,
    String? borrowerId,
    String? borrowerName,
    String? borrowerEmail,
    String? ownerId,
    String? ownerName,
    String? ownerEmail,
    RequestStatus? status,
    String? notes,
    int? proposedDurationDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RequestEntity(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      resourceTitle: resourceTitle ?? this.resourceTitle,
      resourceImageUrl: resourceImageUrl ?? this.resourceImageUrl,
      borrowerId: borrowerId ?? this.borrowerId,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerEmail: borrowerEmail ?? this.borrowerEmail,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      proposedDurationDays: proposedDurationDays ?? this.proposedDurationDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
