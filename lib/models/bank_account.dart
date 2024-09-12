class BankAccount {
  final String id;
  final String bankName;
  final String bankLogo;
  double balance;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.bankLogo,
    required this.balance,
  });

  factory BankAccount.fromFirestore(Map<String, dynamic> data, String id) {
    return BankAccount(
      id: id,
      bankName: data['bankName'] ?? '',
      bankLogo: data['bankLogo'] ?? '',
      balance: (data['balance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bankName': bankName,
      'bankLogo': bankLogo,
      'balance': balance,
    };
  }
}