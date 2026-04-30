import 'package:cloud_firestore/cloud_firestore.dart';

class StatusUpdate {
  final String status;
  final DateTime timestamp;
  final String? note;

  const StatusUpdate({required this.status, required this.timestamp, this.note});

  factory StatusUpdate.fromMap(Map<String, dynamic> m) => StatusUpdate(
    status: m['status'],
    timestamp: (m['timestamp'] as Timestamp).toDate(),
    note: m['note'],
  );

  Map<String, dynamic> toMap() => {
    'status': status,
    'timestamp': Timestamp.fromDate(timestamp),
    'note': note,
  };
}

class DocumentRequest {
  final String? id;
  final String userId;
  final String userName;
  final String documentType;
  final String purpose;
  final String? additionalInfo;
  final String? idImageUrl;
  final String status;
  final String referenceNo;
  final DateTime createdAt;
  final List<StatusUpdate> timeline;

  const DocumentRequest({
    this.id,
    required this.userId,
    required this.userName,
    required this.documentType,
    required this.purpose,
    this.additionalInfo,
    this.idImageUrl,
    required this.status,
    required this.referenceNo,
    required this.createdAt,
    required this.timeline,
  });

  factory DocumentRequest.fromMap(Map<String, dynamic> m, String id) =>
      DocumentRequest(
        id: id,
        userId: m['userId'],
        userName: m['userName'],
        documentType: m['documentType'],
        purpose: m['purpose'],
        additionalInfo: m['additionalInfo'],
        idImageUrl: m['idImageUrl'],
        status: m['status'],
        referenceNo: m['referenceNo'],
        createdAt: (m['createdAt'] as Timestamp).toDate(),
        timeline: (m['timeline'] as List<dynamic>)
            .map((e) => StatusUpdate.fromMap(e))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName,
    'documentType': documentType,
    'purpose': purpose,
    'additionalInfo': additionalInfo,
    'idImageUrl': idImageUrl,
    'status': status,
    'referenceNo': referenceNo,
    'createdAt': Timestamp.fromDate(createdAt),
    'timeline': timeline.map((e) => e.toMap()).toList(),
  };
}
