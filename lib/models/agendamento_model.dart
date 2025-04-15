import 'package:cloud_firestore/cloud_firestore.dart';

class AgendamentoModel {
  final String serviceId;
  final String propertyId;
  final String createdBy;
  final String contractorId;
  final String workerId;
  final String status;
  final double price;
  final bool paymentConfirmed;
  final DateTime serviceDate;
  final DateTime createdAt;
  final String notes;
  final bool confirmedByWorker;
  final bool confirmedByContractor;

  AgendamentoModel({
    required this.serviceId,
    required this.propertyId,
    required this.createdBy,
    required this.contractorId,
    required this.workerId,
    required this.status,
    required this.price,
    required this.paymentConfirmed,
    required this.serviceDate,
    required this.createdAt,
    required this.notes,
    required this.confirmedByWorker,
    required this.confirmedByContractor,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'propertyId': propertyId,
      'createdBy': createdBy,
      'contractorId': contractorId,
      'workerId': workerId,
      'status': status,
      'price': price,
      'paymentConfirmed': paymentConfirmed,
      'serviceDate': serviceDate,
      'createdAt': createdAt,
      'notes': notes,
      'confirmedByWorker': confirmedByWorker,
      'confirmedByContractor': confirmedByContractor,
    };
  }

  factory AgendamentoModel.fromMap(Map<String, dynamic> map, String id) {
    return AgendamentoModel(
      serviceId: map['serviceId'],
      propertyId: map['propertyId'],
      createdBy: map['createdBy'],
      contractorId: map['contractorId'],
      workerId: map['workerId'],
      status: map['status'],
      price: map['price'].toDouble(),
      paymentConfirmed: map['paymentConfirmed'],
      serviceDate: (map['serviceDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      notes: map['notes'],
      confirmedByWorker: map['confirmedByWorker'],
      confirmedByContractor: map['confirmedByContractor'],
    );
  }
  AgendamentoModel copyWith({
    String? serviceId,
    String? propertyId,
    String? createdBy,
    String? contractorId,
    String? workerId,
    String? status,
    double? price,
    bool? paymentConfirmed,
    DateTime? serviceDate,
    DateTime? createdAt,
    String? notes,
    bool? confirmedByWorker,
    bool? confirmedByContractor,
  }) {
    return AgendamentoModel(
      serviceId: serviceId ?? this.serviceId,
      propertyId: propertyId ?? this.propertyId,
      createdBy: createdBy ?? this.createdBy,
      contractorId: contractorId ?? this.contractorId,
      workerId: workerId ?? this.workerId,
      status: status ?? this.status,
      price: price ?? this.price,
      paymentConfirmed: paymentConfirmed ?? this.paymentConfirmed,
      serviceDate: serviceDate ?? this.serviceDate,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      confirmedByWorker: confirmedByWorker ?? this.confirmedByWorker,
      confirmedByContractor:
          confirmedByContractor ?? this.confirmedByContractor,
    );
  }
}
