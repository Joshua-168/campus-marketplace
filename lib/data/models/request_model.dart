import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/request_entity.dart';

/// Data Model for Request document with Firestore serialization.
class RequestModel extends RequestEntity {
  const RequestModel({
    required super.id,
    required super.resourceId,
    required super.resourceTitle,
    required super.resourceImageUrl,
    required super.borrowerId,
    required super.borrowerName,
    required super.borrowerEmail,
    required super.ownerId,
    required super.ownerName,
    required super.ownerEmail,
    required super.status,
    required super.notes,
    required super.proposedDurationDays,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RequestModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return RequestModel(
      id: snapshot.id,
      resourceId: data['resourceId'] ?? '',
      resourceTitle: data['resourceTitle'] ?? '',
      resourceImageUrl: data['resourceImageUrl'] ?? '',
      borrowerId: data['borrowerId'] ?? '',
      borrowerName: data['borrowerName'] ?? '',
      borrowerEmail: data['borrowerEmail'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      status: RequestStatus.fromString(data['status'] ?? ''),
      notes: data['notes'] ?? '',
      proposedDurationDays: data['proposedDurationDays'] ?? 7,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'resourceId': resourceId,
      'resourceTitle': resourceTitle,
      'resourceImageUrl': resourceImageUrl,
      'borrowerId': borrowerId,
      'borrowerName': borrowerName,
      'borrowerEmail': borrowerEmail,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'status': status.displayName,
      'notes': notes,
      'proposedDurationDays': proposedDurationDays,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory RequestModel.fromEntity(RequestEntity entity) {
    return RequestModel(
      id: entity.id,
      resourceId: entity.resourceId,
      resourceTitle: entity.resourceTitle,
      resourceImageUrl: entity.resourceImageUrl,
      borrowerId: entity.borrowerId,
      borrowerName: entity.borrowerName,
      borrowerEmail: entity.borrowerEmail,
      ownerId: entity.ownerId,
      ownerName: entity.ownerName,
      ownerEmail: entity.ownerEmail,
      status: entity.status,
      notes: entity.notes,
      proposedDurationDays: entity.proposedDurationDays,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  RequestEntity toEntity() {
    return RequestEntity(
      id: id,
      resourceId: resourceId,
      resourceTitle: resourceTitle,
      resourceImageUrl: resourceImageUrl,
      borrowerId: borrowerId,
      borrowerName: borrowerName,
      borrowerEmail: borrowerEmail,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      status: status,
      notes: notes,
      proposedDurationDays: proposedDurationDays,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
