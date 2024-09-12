import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialGoal {
  final String id;
  final String title;
  final double targetAmount;
  double currentAmount;
  final String userId;

  FinancialGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.userId,
    this.currentAmount = 0,
  });

  double get progress {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  FinancialGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? userId,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      userId: userId ?? this.userId,
    );
  }

  factory FinancialGoal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print('Convertendo documento Firestore para FinancialGoal: ${doc.id}');
    return FinancialGoal(
      id: doc.id,
      title: data['title'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0).toDouble(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    print('Convertendo FinancialGoal para documento Firestore: $id');
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'userId': userId,
    };
  }

  @override
  String toString() {
    return 'FinancialGoal(id: $id, title: $title, targetAmount: $targetAmount, currentAmount: $currentAmount, userId: $userId)';
  }
}