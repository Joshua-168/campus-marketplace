import 'package:flutter_test/flutter_test.dart';
import 'package:campus_marketplace/data/models/user_model.dart';
import 'package:campus_marketplace/domain/entities/user_entity.dart';

void main() {
  group('UserModel Serialization & Entity Mapping', () {
    final now = DateTime.now();
    final tUserModel = UserModel(
      id: 'usr_123',
      name: 'Aarav Sharma',
      email: 'aarav@citchennai.net',
      campusName: 'Chennai Institute of Technology',
      joinedAt: now,
      lastLogin: now,
      isEmailVerified: true,
    );

    test('should convert UserModel to Firestore Map correctly', () {
      final map = tUserModel.toFirestore();

      expect(map['name'], equals('Aarav Sharma'));
      expect(map['email'], equals('aarav@citchennai.net'));
      expect(map['campusName'], equals('Chennai Institute of Technology'));
      expect(map['isEmailVerified'], isTrue);
    });

    test('should convert UserEntity to UserModel and back without data loss', () {
      final entity = UserEntity(
        id: 'usr_456',
        name: 'Ananya Iyer',
        email: 'ananya@citchennai.net',
        campusName: 'Chennai Institute of Technology',
        joinedAt: now,
        lastLogin: now,
        isEmailVerified: true,
      );

      final model = UserModel.fromEntity(entity);
      final convertedEntity = model.toEntity();

      expect(convertedEntity.id, equals(entity.id));
      expect(convertedEntity.name, equals(entity.name));
      expect(convertedEntity.email, equals(entity.email));
      expect(convertedEntity.campusName, equals(entity.campusName));
    });
  });
}
