import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final double amount;
  final String description;
  final DateTime date;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
    };
  }
}