import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uttopic/models/transaction.dart' as TransactionModel;
import 'package:uttopic/models/bank_account.dart';

class User {
  final String id;
  final String name;
  final String email;
  String profilePicUrl;
  final List<TransactionModel.Transaction> transactions;
  double balance;
  int level;
  int points;
  int achievements;
  
  // Campos de despesas
  double rent;
  double housing;
  double creditCard;
  double mobility;
  double food;
  double utilities;
  double electricity;
  double entertainment;
  double onlineShopping;
  double financing;
  double totalExpenses;

  // Campos de receitas
  double salary;
  double extraIncome;
  double investments;
  Map<String, double> customIncomes;
  double totalIncomes;

  // Novo campo para contas bancárias
  List<BankAccount> bankAccounts;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicUrl = '',
    this.transactions = const [],
    this.balance = 0,
    this.level = 1,
    this.points = 0,
    this.achievements = 0,
    this.rent = 0,
    this.housing = 0,
    this.creditCard = 0,
    this.mobility = 0,
    this.food = 0,
    this.utilities = 0,
    this.electricity = 0,
    this.entertainment = 0,
    this.onlineShopping = 0,
    this.financing = 0,
    this.totalExpenses = 0,
    this.salary = 0,
    this.extraIncome = 0,
    this.investments = 0,
    this.customIncomes = const {},
    this.totalIncomes = 0,
    this.bankAccounts = const [],
  });

  double get income => transactions.where((t) => t.amount > 0).fold<double>(0, (sum, t) => sum + t.amount);
  double get expenses => transactions.where((t) => t.amount < 0).fold<double>(0, (sum, t) => sum + t.amount).abs();

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePicUrl: data['profilePicUrl'] ?? '',
      transactions: (data['transactions'] as List? ?? [])
          .map((t) => TransactionModel.Transaction.fromMap(t))
          .toList(),
      balance: (data['balance'] ?? 0).toDouble(),
      level: data['level'] ?? 1,
      points: data['points'] ?? 0,
      achievements: data['achievements'] ?? 0,
      rent: (data['rent'] ?? 0).toDouble(),
      housing: (data['housing'] ?? 0).toDouble(),
      creditCard: (data['creditCard'] ?? 0).toDouble(),
      mobility: (data['mobility'] ?? 0).toDouble(),
      food: (data['food'] ?? 0).toDouble(),
      utilities: (data['utilities'] ?? 0).toDouble(),
      electricity: (data['electricity'] ?? 0).toDouble(),
      entertainment: (data['entertainment'] ?? 0).toDouble(),
      onlineShopping: (data['onlineShopping'] ?? 0).toDouble(),
      financing: (data['financing'] ?? 0).toDouble(),
      totalExpenses: (data['totalExpenses'] ?? 0).toDouble(),
      salary: (data['salary'] ?? 0).toDouble(),
      extraIncome: (data['extraIncome'] ?? 0).toDouble(),
      investments: (data['investments'] ?? 0).toDouble(),
      customIncomes: Map<String, double>.from(data['customIncomes'] ?? {}),
      totalIncomes: (data['totalIncomes'] ?? 0).toDouble(),
      bankAccounts: (data['bankAccounts'] as List? ?? [])
          .map((b) => BankAccount.fromFirestore(b, b['id']))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'profilePicUrl': profilePicUrl,
      'balance': balance,
      'level': level,
      'points': points,
      'achievements': achievements,
      'rent': rent,
      'housing': housing,
      'creditCard': creditCard,
      'mobility': mobility,
      'food': food,
      'utilities': utilities,
      'electricity': electricity,
      'entertainment': entertainment,
      'onlineShopping': onlineShopping,
      'financing': financing,
      'totalExpenses': totalExpenses,
      'salary': salary,
      'extraIncome': extraIncome,
      'investments': investments,
      'customIncomes': customIncomes,
      'totalIncomes': totalIncomes,
      'bankAccounts': bankAccounts.map((b) => b.toFirestore()).toList(),
    };
  }

  void updateProfilePicture(String url) {
    profilePicUrl = url;
  }

  void addTransaction(TransactionModel.Transaction transaction) {
    transactions.add(transaction);
    balance += transaction.amount;
    if (transaction.amount > 0) {
      totalIncomes += transaction.amount;
    } else {
      totalExpenses += transaction.amount.abs();
    }
  }

  void updateExpense(String category, double amount) {
    switch (category) {
      case 'rent':
        rent = amount;
        break;
      case 'housing':
        housing = amount;
        break;
      case 'creditCard':
        creditCard = amount;
        break;
      case 'mobility':
        mobility = amount;
        break;
      case 'food':
        food = amount;
        break;
      case 'utilities':
        utilities = amount;
        break;
      case 'electricity':
        electricity = amount;
        break;
      case 'entertainment':
        entertainment = amount;
        break;
      case 'onlineShopping':
        onlineShopping = amount;
        break;
      case 'financing':
        financing = amount;
        break;
      default:
        print('Categoria de despesa não reconhecida: $category');
        break;
    }
    calculateTotalExpenses();
  }

  void calculateTotalExpenses() {
    totalExpenses = rent + housing + creditCard + mobility + food + utilities + 
                    electricity + entertainment + onlineShopping + financing;
  }

  void updateIncome(String category, double amount) {
    switch (category) {
      case 'salary':
        salary = amount;
        break;
      case 'extraIncome':
        extraIncome = amount;
        break;
      case 'investments':
        investments = amount;
        break;
      default:
        customIncomes[category] = amount;
        break;
    }
    calculateTotalIncomes();
  }

  void calculateTotalIncomes() {
    totalIncomes = salary + extraIncome + investments + 
                   customIncomes.values.fold(0, (sum, value) => sum + value);
  }

  void addBankAccount(BankAccount account) {
    bankAccounts.add(account);
    calculateTotalBalance();
  }

  void updateBankAccount(String accountId, double newBalance) {
    int index = bankAccounts.indexWhere((account) => account.id == accountId);
    if (index != -1) {
      bankAccounts[index].balance = newBalance;
      calculateTotalBalance();
    }
  }

  void deleteBankAccount(String accountId) {
    bankAccounts.removeWhere((account) => account.id == accountId);
    calculateTotalBalance();
  }

  void calculateTotalBalance() {
    balance = bankAccounts.fold(0, (sum, account) => sum + account.balance);
  }
}