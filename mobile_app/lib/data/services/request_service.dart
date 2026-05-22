import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/document_request.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../core/utils/image_utils.dart';

class RequestService {
  final _db = FirebaseFirestore.instance;
  //final _storage = FirebaseStorage.instance;

  CollectionReference get _col => _db.collection(AppConstants.requestsCol);

  // Stream<List<DocumentRequest>> userRequests(String uid) =>
  //     _col.where('userId', isEqualTo: uid)
  //         .orderBy('createdAt', descending: true)
  //         .snapshots()
  //         .map((s) => s.docs
  //             .map((d) => DocumentRequest.fromMap(d.data() as Map<String, dynamic>, d.id))
  //             .toList());
  Stream<List<DocumentRequest>> userRequests(String uid) =>
      _col.where('userId', isEqualTo: uid).snapshots().map((s) {
        final requests = s.docs
            .map((d) =>
                DocumentRequest.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList();
        // Sort locally instead of using orderBy
        requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return requests;
      });

  Stream<DocumentRequest?> requestById(String id) =>
      _col.doc(id).snapshots().map((s) => s.exists
          ? DocumentRequest.fromMap(s.data() as Map<String, dynamic>, s.id)
          : null);

  Future<DocumentRequest> submitRequest({
    required String userId,
    required String userName,
    required String documentType,
    required String purpose,
    String? additionalInfo,
    File? idImage,
  }) async {
    String? idUrl;
    if (idImage != null) {
      idUrl = await ImageUtils.toBase64(idImage);
      if (idUrl == "TOO_LARGE") {
        throw Exception('too large');
      }
    } else {
      // Resident is verified — fetch their ID from user profile
      try {
        final userDoc = await _db
            .collection(AppConstants.usersCol)
            .doc(userId)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          idUrl = data['idImageUrl'] as String?;
        }
      } catch (_) {}
    }

    final now = DateTime.now();
    final request = DocumentRequest(
      userId: userId,
      userName: userName,
      documentType: documentType,
      purpose: purpose,
      additionalInfo: additionalInfo,
      idImageUrl: idUrl,
      status: AppConstants.statusRequested,
      referenceNo: AppUtils.generateRefNo(documentType),
      createdAt: now,
      timeline: [
        StatusUpdate(
          status: AppConstants.statusRequested,
          timestamp: now,
          note: 'Your request has been submitted and is being reviewed.',
        ),
      ],
    );

    final doc = await _col.add(request.toMap());
    return request.copyWith(id: doc.id);
  }

  // Admin: update request status
  Future<void> updateStatus(String requestId, String status,
      {String? note}) async {
    await _col.doc(requestId).update({
      'status': status,
      'timeline': FieldValue.arrayUnion([
        StatusUpdate(
          status: status,
          timestamp: DateTime.now(),
          note: note,
        ).toMap(),
      ]),
    });
  }

  Future<void> cancelRequest(String requestId) async {
    await _col.doc(requestId).update({
      'status': AppConstants.statusCanceled,
      'timeline': FieldValue.arrayUnion([
        StatusUpdate(
          status: AppConstants.statusCanceled,
          timestamp: DateTime.now(),
          note: 'The request is canceled.',
        ).toMap(),
      ]),
    });
  }
}

extension _RequestCopyWith on DocumentRequest {
  DocumentRequest copyWith({String? id}) => DocumentRequest(
        id: id ?? this.id,
        userId: userId,
        userName: userName,
        documentType: documentType,
        purpose: purpose,
        additionalInfo: additionalInfo,
        idImageUrl: idImageUrl,
        status: status,
        referenceNo: referenceNo,
        createdAt: createdAt,
        timeline: timeline,
      );
}
