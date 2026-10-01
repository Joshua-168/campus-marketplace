import 'package:flutter_test/flutter_test.dart';
import 'package:campus_marketplace/domain/entities/resource_entity.dart';

void main() {
  group('Resource Enums Parsing Tests', () {
    test('ResourceCategory fromString should match enum correctly', () {
      expect(ResourceCategory.fromString('Books'), equals(ResourceCategory.books));
      expect(ResourceCategory.fromString('Electronics'), equals(ResourceCategory.electronics));
      expect(ResourceCategory.fromString('Lab Equipment'), equals(ResourceCategory.labEquipment));
      expect(ResourceCategory.fromString('NonExistent'), equals(ResourceCategory.others));
    });

    test('ResourceCondition fromString should match enum correctly', () {
      expect(ResourceCondition.fromString('Brand New'), equals(ResourceCondition.brandNew));
      expect(ResourceCondition.fromString('Like New'), equals(ResourceCondition.likeNew));
      expect(ResourceCondition.fromString('Good'), equals(ResourceCondition.good));
      expect(ResourceCondition.fromString('Unknown'), equals(ResourceCondition.good));
    });

    test('ResourceAvailability fromString should match enum correctly', () {
      expect(ResourceAvailability.fromString('Available'), equals(ResourceAvailability.available));
      expect(ResourceAvailability.fromString('Borrowed'), equals(ResourceAvailability.borrowed));
      expect(ResourceAvailability.fromString('Sold'), equals(ResourceAvailability.sold));
    });
  });
}
