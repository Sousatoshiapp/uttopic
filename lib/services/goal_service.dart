import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uttopic/models/financial_goal.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<FinancialGoal>> getUserGoals(String userId) {
    print('Buscando metas para o usuário: $userId');
    return _firestore
        .collection('goals')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('Número de metas encontradas: ${snapshot.docs.length}');
          return snapshot.docs
              .map((doc) {
                print('Convertendo meta: ${doc.id}');
                return FinancialGoal.fromFirestore(doc);
              })
              .toList();
        });
  }

  Future<void> updateGoalProgress(String goalId, double amount) async {
    print('Atualizando progresso da meta: $goalId com valor: $amount');
    DocumentReference goalRef = _firestore.collection('goals').doc(goalId);
    
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(goalRef);
        
        if (!snapshot.exists) {
          throw Exception("Meta não encontrada!");
        }
        
        FinancialGoal goal = FinancialGoal.fromFirestore(snapshot);
        print('Meta atual: $goal');
        
        double newCurrentAmount = goal.currentAmount + amount;
        
        transaction.update(goalRef, {'currentAmount': newCurrentAmount});
        
        print('Meta atualizada no Firestore. Novo valor: $newCurrentAmount');
      });
    } catch (e) {
      print('Erro ao atualizar meta: $e');
      throw e;
    }
  }

  Future<void> addGoal(FinancialGoal goal) async {
    print('Adicionando nova meta: ${goal.title}');
    try {
      DocumentReference docRef = await _firestore.collection('goals').add({
        'title': goal.title,
        'targetAmount': goal.targetAmount,
        'currentAmount': 0,
        'userId': goal.userId,
      });
      print('Nova meta adicionada com sucesso. ID: ${docRef.id}');
    } catch (e) {
      print('Erro ao adicionar nova meta: $e');
      throw e;
    }
  }

  Future<void> updateGoal(String goalId, String title, double targetAmount) async {
    try {
      await _firestore.collection('goals').doc(goalId).update({
        'title': title,
        'targetAmount': targetAmount,
      });
    } catch (e) {
      print('Erro ao atualizar meta: $e');
      throw e;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await _firestore.collection('goals').doc(goalId).delete();
    } catch (e) {
      print('Erro ao excluir meta: $e');
      throw e;
    }
  }
}
