import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/exceptions.dart';

/// Low-level Cloud Firestore Service wrapper for CRUD operations & real-time streams.
class FirestoreService {
  final FirebaseFirestore? firestore;

  FirestoreService({this.firestore});

  /// Get Document Snapshot
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String docId,
  }) async {
    if (firestore == null) throw const ServerException('Firestore service is unavailable.');
    try {
      return await firestore!.collection(collection).doc(docId).get();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore error', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Create or Set Document
  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    if (firestore == null) throw const ServerException('Firestore service is unavailable.');
    try {
      await firestore!
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: merge));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore set failed', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Update Document Fields
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    if (firestore == null) throw const ServerException('Firestore service is unavailable.');
    try {
      await firestore!.collection(collection).doc(docId).update(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore update failed', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Delete Document
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    if (firestore == null) throw const ServerException('Firestore service is unavailable.');
    try {
      await firestore!.collection(collection).doc(docId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore delete failed', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Stream Document
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument({
    required String collection,
    required String docId,
  }) {
    if (firestore == null) return const Stream.empty();
    return firestore!.collection(collection).doc(docId).snapshots();
  }

  /// Query Collection Stream
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection({
    required String collection,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)? queryBuilder,
  }) {
    if (firestore == null) return const Stream.empty();
    Query<Map<String, dynamic>> query = firestore!.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  /// Get Collection Documents Once
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection({
    required String collection,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)? queryBuilder,
  }) async {
    if (firestore == null) throw const ServerException('Firestore service is unavailable.');
    try {
      Query<Map<String, dynamic>> query = firestore!.collection(collection);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      return await query.get();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore query failed', code: e.code);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
