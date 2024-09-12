import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  static Future<void> verifyGoalsCollection() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print('Nenhum usuário autenticado.');
      return;
    }

    try {
      final QuerySnapshot goalSnapshot = await _firestore
          .collection('goals')
          .where('userId', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (goalSnapshot.docs.isEmpty) {
        print('Nenhuma meta encontrada. Criando meta de exemplo...');
        
        await _firestore.collection('goals').add({
          'userId': currentUser.uid,
          'title': 'Meta de Exemplo',
          'targetAmount': 1000,
          'currentAmount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('Meta de exemplo criada com sucesso.');
      } else {
        print('Coleção de metas existe e contém dados.');
      }
    } catch (e) {
      print('Erro ao verificar/criar coleção de metas: $e');
    }
  }
}