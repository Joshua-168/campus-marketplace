import 'package:rxdart/rxdart.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/resource_entity.dart';
import '../../domain/repositories/resource_repository.dart';
import '../models/resource_model.dart';
import '../services/firestore_service.dart';

class ResourceRepositoryImpl implements ResourceRepository {
  final FirestoreService firestoreService;
  static const String _collectionName = 'Resources';

  // In-memory sample data store with authentic Indian student owner profiles
  final BehaviorSubject<List<ResourceEntity>> _localResourcesSubject =
      BehaviorSubject<List<ResourceEntity>>.seeded([
    ResourceEntity(
      id: 'res_sample_1',
      title: 'Calculus: Early Transcendentals (9th Ed)',
      description: 'Standard textbook for MATH 101/102. Pristine condition with clean pages.',
      category: ResourceCategory.books,
      condition: ResourceCondition.likeNew,
      availability: ResourceAvailability.available,
      price: 0,
      depositAmount: 500,
      ownerId: 'sample_owner_1',
      ownerName: 'Aarav Sharma',
      ownerEmail: 'aarav@citchennai.net',
      campusName: 'Chennai Institute of Technology',
      imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      updatedAt: DateTime.now(),
    ),
    ResourceEntity(
      id: 'res_sample_2',
      title: 'TI-84 Plus CE Graphing Calculator',
      description: 'Essential calculator for engineering & statistics courses. Includes USB charger.',
      category: ResourceCategory.electronics,
      condition: ResourceCondition.good,
      availability: ResourceAvailability.available,
      price: 499,
      depositAmount: 1000,
      ownerId: 'sample_owner_2',
      ownerName: 'Ananya Iyer',
      ownerEmail: 'ananya@citchennai.net',
      campusName: 'Chennai Institute of Technology',
      imageUrl: 'https://images.unsplash.com/photo-1611125832047-1d7ad1e8e48a?auto=format&fit=crop&w=600&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
    ResourceEntity(
      id: 'res_sample_3',
      title: 'Arduino Ultimate Starter Lab Kit',
      description: 'Complete kit with UNO R3, breadboards, sensors, LEDs, and stepper motors for robotics lab.',
      category: ResourceCategory.projectKits,
      condition: ResourceCondition.brandNew,
      availability: ResourceAvailability.available,
      price: 0,
      depositAmount: 750,
      ownerId: 'sample_owner_3',
      ownerName: 'Rohan Verma',
      ownerEmail: 'rohan@citchennai.net',
      campusName: 'Chennai Institute of Technology',
      imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=600&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    ),
    ResourceEntity(
      id: 'res_sample_4',
      title: 'Digital Oscilloscope & Multimeter Probe',
      description: 'Handheld 100MHz dual-channel oscilloscope probe for EEE/ECE circuit analysis labs.',
      category: ResourceCategory.labEquipment,
      condition: ResourceCondition.likeNew,
      availability: ResourceAvailability.available,
      price: 299,
      depositAmount: 1200,
      ownerId: 'sample_owner_4',
      ownerName: 'Priya Patel',
      ownerEmail: 'priya@citchennai.net',
      campusName: 'Chennai Institute of Technology',
      imageUrl: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=600&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
    ResourceEntity(
      id: 'res_sample_5',
      title: 'Structural Analysis & Steel Design Manual',
      description: 'Comprehensive reference textbook for Civil Engineering 3rd year coursework.',
      category: ResourceCategory.books,
      condition: ResourceCondition.good,
      availability: ResourceAvailability.available,
      price: 0,
      depositAmount: 300,
      ownerId: 'sample_owner_5',
      ownerName: 'Karthik Subramanian',
      ownerEmail: 'karthik@citchennai.net',
      campusName: 'Chennai Institute of Technology',
      imageUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?auto=format&fit=crop&w=600&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now(),
    ),
  ]);

  ResourceRepositoryImpl({required this.firestoreService});

  @override
  Future<Result<List<ResourceEntity>>> getResources({
    ResourceCategory? category,
    ResourceAvailability? availability,
    int limit = 20,
  }) async {
    if (firestoreService.firestore == null) {
      var list = _localResourcesSubject.value;
      if (category != null) {
        list = list.where((i) => i.category == category).toList();
      }
      if (availability != null) {
        list = list.where((i) => i.availability == availability).toList();
      }
      return Result.success(list);
    }
    try {
      final snapshot = await firestoreService.getCollection(
        collection: _collectionName,
        queryBuilder: (query) {
          var q = query.orderBy('createdAt', descending: true).limit(limit);
          if (category != null) {
            q = q.where('category', isEqualTo: category.displayName);
          }
          if (availability != null) {
            q = q.where('availability', isEqualTo: availability.displayName);
          }
          return q;
        },
      );

      final resources = snapshot.docs
          .map((doc) => ResourceModel.fromFirestore(doc).toEntity())
          .toList();

      return Result.success(resources);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<ResourceEntity>> streamResources({
    ResourceCategory? category,
    ResourceAvailability? availability,
  }) {
    if (firestoreService.firestore == null) {
      return _localResourcesSubject.stream.map((list) {
        var filtered = list;
        if (category != null) {
          filtered = filtered.where((i) => i.category == category).toList();
        }
        if (availability != null) {
          filtered = filtered.where((i) => i.availability == availability).toList();
        }
        return filtered;
      });
    }
    return firestoreService.streamCollection(
      collection: _collectionName,
      queryBuilder: (query) {
        var q = query.orderBy('createdAt', descending: true);
        if (category != null) {
          q = q.where('category', isEqualTo: category.displayName);
        }
        if (availability != null) {
          q = q.where('availability', isEqualTo: availability.displayName);
        }
        return q;
      },
    ).map((snapshot) {
      return snapshot.docs
          .map((doc) => ResourceModel.fromFirestore(doc).toEntity())
          .toList();
    });
  }

  @override
  Future<Result<ResourceEntity>> getResourceById(String id) async {
    if (firestoreService.firestore == null) {
      final item = _localResourcesSubject.value.firstWhere(
        (i) => i.id == id,
        orElse: () => throw const NotFoundFailure('Resource listing not found'),
      );
      return Result.success(item);
    }
    try {
      final doc = await firestoreService.getDocument(
        collection: _collectionName,
        docId: id,
      );

      if (!doc.exists) {
        return const Result.failure(NotFoundFailure('Resource listing not found'));
      }

      final model = ResourceModel.fromFirestore(doc);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<ResourceEntity?> streamResourceById(String id) {
    if (firestoreService.firestore == null) {
      return _localResourcesSubject.stream.map((list) {
        return list.firstWhere((i) => i.id == id, orElse: () => _localResourcesSubject.value.first);
      });
    }
    return firestoreService.streamDocument(
      collection: _collectionName,
      docId: id,
    ).map((doc) {
      if (!doc.exists) return null;
      return ResourceModel.fromFirestore(doc).toEntity();
    });
  }

  @override
  Future<Result<String>> createResource(ResourceEntity resource) async {
    final current = List<ResourceEntity>.from(_localResourcesSubject.value);
    current.insert(0, resource);
    _localResourcesSubject.add(current);

    if (firestoreService.firestore == null) {
      return Result.success(resource.id);
    }

    try {
      final model = ResourceModel.fromEntity(resource);
      await firestoreService.setDocument(
        collection: _collectionName,
        docId: resource.id,
        data: model.toFirestore(),
      );
      return Result.success(resource.id);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateResource(ResourceEntity resource) async {
    final current = List<ResourceEntity>.from(_localResourcesSubject.value);
    final index = current.indexWhere((i) => i.id == resource.id);
    if (index != -1) {
      current[index] = resource;
      _localResourcesSubject.add(current);
    }

    if (firestoreService.firestore == null) {
      return const Result.success(null);
    }

    try {
      final model = ResourceModel.fromEntity(resource);
      await firestoreService.updateDocument(
        collection: _collectionName,
        docId: resource.id,
        data: model.toFirestore(),
      );
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteResource(String id) async {
    final current = List<ResourceEntity>.from(_localResourcesSubject.value);
    current.removeWhere((i) => i.id == id);
    _localResourcesSubject.add(current);

    if (firestoreService.firestore == null) {
      return const Result.success(null);
    }

    try {
      await firestoreService.deleteDocument(
        collection: _collectionName,
        docId: id,
      );
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ResourceEntity>>> getUserResources(String userId) async {
    var list = _localResourcesSubject.value.where((i) => i.ownerId == userId).toList();
    if (firestoreService.firestore == null) {
      return Result.success(list);
    }
    try {
      final snapshot = await firestoreService.getCollection(
        collection: _collectionName,
        queryBuilder: (query) => query.where('ownerId', isEqualTo: userId),
      );

      final resources = snapshot.docs
          .map((doc) => ResourceModel.fromFirestore(doc).toEntity())
          .toList();

      return Result.success(resources);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ResourceEntity>>> searchResources(String queryText) async {
    final queryLower = queryText.toLowerCase();
    final list = _localResourcesSubject.value.where((item) =>
        item.title.toLowerCase().contains(queryLower) ||
        item.description.toLowerCase().contains(queryLower) ||
        item.category.displayName.toLowerCase().contains(queryLower) ||
        item.ownerName.toLowerCase().contains(queryLower)).toList();

    if (firestoreService.firestore == null) {
      return Result.success(list);
    }

    try {
      final snapshot = await firestoreService.getCollection(
        collection: _collectionName,
      );

      final resources = snapshot.docs
          .map((doc) => ResourceModel.fromFirestore(doc).toEntity())
          .where((item) =>
              item.title.toLowerCase().contains(queryLower) ||
              item.description.toLowerCase().contains(queryLower) ||
              item.category.displayName.toLowerCase().contains(queryLower) ||
              item.ownerName.toLowerCase().contains(queryLower))
          .toList();

      return Result.success(resources);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
