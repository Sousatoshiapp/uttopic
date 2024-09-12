import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uttopic/models/user.dart';
import 'package:uttopic/models/transaction.dart' as TransactionModel;
import 'package:uttopic/models/bank_account.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> getUser(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return User.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateUser(User user) {
    return _firestore.collection('users').doc(user.id).update(user.toFirestore());
  }

  Future<void> addTransaction(String userId, TransactionModel.Transaction transaction) async {
    await _firestore.collection('users').doc(userId).collection('transactions').add(transaction.toFirestore());
    
    // Atualizar o saldo do usuário
    DocumentReference userRef = _firestore.collection('users').doc(userId);
    await _firestore.runTransaction((transactionFirestore) async {
      DocumentSnapshot snapshot = await transactionFirestore.get(userRef);
      if (snapshot.exists) {
        User user = User.fromFirestore(snapshot);
        user.balance += transaction.amount;
        transactionFirestore.update(userRef, {'balance': user.balance});
      }
    });
  }

  Future<void> updateUserFinancialData(String userId, double balance, double income, double expenses) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'balance': balance,
        'income': income,
        'expenses': expenses,
      });
    } catch (e) {
      print('Erro ao atualizar dados financeiros: $e');
      throw e;
    }
  }

  Future<void> updateUserExpenses(String userId, Map<String, double> expenses) async {
    try {
      await _firestore.collection('users').doc(userId).update(expenses);
    } catch (e) {
      print('Erro ao atualizar despesas: $e');
      throw e;
    }
  }

  Future<void> updateTotalExpenses(String userId, double totalExpenses) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'totalExpenses': totalExpenses,
      });
    } catch (e) {
      print('Erro ao atualizar total de despesas: $e');
      throw e;
    }
  }

  Future<void> updateUserIncomes(String userId, Map<String, double> incomes) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'salary': incomes['salary'] ?? 0,
        'extraIncome': incomes['extraIncome'] ?? 0,
        'investments': incomes['investments'] ?? 0,
        'customIncomes': incomes..removeWhere((key, value) => ['salary', 'extraIncome', 'investments', 'totalIncomes'].contains(key)),
        'totalIncomes': incomes['totalIncomes'] ?? 0,
      });
    } catch (e) {
      print('Erro ao atualizar receitas: $e');
      throw e;
    }
  }

  Future<void> updateUserTotalIncomes(String userId, double totalIncomes) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'totalIncomes': totalIncomes,
      });
    } catch (e) {
      print('Erro ao atualizar total de receitas: $e');
      throw e;
    }
  }

  Future<double> getTotalIncomes(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return (userData['totalIncomes'] ?? 0).toDouble();
    }
    return 0;
  }

  Future<void> updateProfilePicture(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profilePicUrl': imageUrl,
      });
    } catch (e) {
      print('Erro ao atualizar a foto de perfil: $e');
      throw e;
    }
  }

  // Novos métodos para gerenciar contas bancárias

  Future<List<BankAccount>> getBankAccounts(String userId) async {
    var snapshot = await _firestore.collection('users').doc(userId).collection('bankAccounts').get();
    return snapshot.docs.map((doc) => BankAccount.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<void> addBankAccount(String userId, String bankName, double balance) async {
    await _firestore.collection('users').doc(userId).collection('bankAccounts').add({
      'bankName': bankName,
      'bankLogo': _getBankLogo(bankName),
      'balance': balance,
    });
    await updateTotalBalance(userId);
  }

  Future<void> updateBankAccount(String userId, String accountId, double newBalance) async {
    await _firestore.collection('users').doc(userId).collection('bankAccounts').doc(accountId).update({
      'balance': newBalance,
    });
    await updateTotalBalance(userId);
  }

  Future<void> deleteBankAccount(String userId, String accountId) async {
    await _firestore.collection('users').doc(userId).collection('bankAccounts').doc(accountId).delete();
    await updateTotalBalance(userId);
  }

  Future<void> updateTotalBalance(String userId) async {
    var accounts = await getBankAccounts(userId);
    double totalBalance = accounts.fold(0, (sum, account) => sum + account.balance);
    await _firestore.collection('users').doc(userId).update({'balance': totalBalance});
  }

  String _getBankLogo(String bankName) {
    // Implemente a lógica para obter a URL do logo do banco
    // Você pode usar um mapa de bancos para logos ou uma API externa
    return 'https://example.com/bank_logos/$bankName.png';
  }
}