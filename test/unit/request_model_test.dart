import 'package:flutter_test/flutter_test.dart';
import 'package:campus_marketplace/data/models/request_model.dart';
import 'package:campus_marketplace/domain/entities/request_entity.dart';

void main() {
  group('RequestModel Unit Tests', () {
    test('RequestStatus string conversion should parse correctly', () {
      expect(RequestStatus.fromString('Pending'), equals(RequestStatus.pending));
      expect(RequestStatus.fromString('Approved'), equals(RequestStatus.approved));
      expect(RequestStatus.fromString('Rejected'), equals(RequestStatus.rejected));
      expect(RequestStatus.fromString('Completed'), equals(RequestStatus.completed));
    });

    test('RequestModel should serialize to Firestore map properly', () {
      final now = DateTime.now();
      final model = RequestModel(
        id: 'req_100',
        resourceId: 'res_200',
        resourceTitle: 'Calculus Early Transcendentals',
        resourceImageUrl: 'https://example.com/book.jpg',
        borrowerId: 'user_a',
        borrowerName: 'Bob Student',
        borrowerEmail: 'bob@stanford.edu',
        ownerId: 'user_b',
        ownerName: 'Alice Owner',
        ownerEmail: 'alice@stanford.edu',
        status: RequestStatus.pending,
        notes: 'Need for midterm exam preparation',
        proposedDurationDays: 7,
        createdAt: now,
        updatedAt: now,
      );

      final map = model.toFirestore();

      expect(map['resourceId'], equals('res_200'));
      expect(map['resourceTitle'], equals('Calculus Early Transcendentals'));
      expect(map['borrowerName'], equals('Bob Student'));
      expect(map['status'], equals('Pending'));
      expect(map['proposedDurationDays'], equals(7));
    });
  });
}
