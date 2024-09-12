import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> createUserDocument(User user, String name, {
  double initialTotalSavings = 0,
  double initialMonthlyBudget = 0,
  String accountType = 'free',
  Map<String, bool>? notificationPreferences,
}) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userDocRef = _firestore.collection('users').doc(user.uid);

  try {
    // Verifica se o documento já existe
    final docSnapshot = await userDocRef.get();
    if (docSnapshot.exists) {
      print('Documento de usuário já existe. Atualizando lastLogin.');
      await userDocRef.update({'lastLogin': FieldValue.serverTimestamp()});
      return;
    }

    // Cria o documento do usuário
    final userData = {
      'uid': user.uid,
      'name': name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'profilePictureUrl': user.photoURL ?? '',
      'totalSavings': initialTotalSavings,
      'monthlyBudget': initialMonthlyBudget,
      'notificationPreferences': notificationPreferences ?? {
        'emailNotifications': true,
        'pushNotifications': true,
      },
      'accountType': accountType,
    };

    await userDocRef.set(userData);
    print('Documento de usuário criado com sucesso!');

    // Cria uma meta inicial para o usuário
    await _firestore.collection('goals').add({
      'userId': user.uid,
      'title': 'Minha Primeira Meta',
      'targetAmount': 1000.0,
      'currentAmount': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    print('Meta inicial criada para o usuário.');

    // Verifica se a meta foi criada com sucesso
    final goalSnapshot = await _firestore
        .collection('goals')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (goalSnapshot.docs.isEmpty) {
      throw Exception('Falha ao criar a meta inicial.');
    }

  } catch (e) {
    print('Erro ao criar/atualizar documento de usuário ou meta inicial: $e');
    // Você pode querer lançar uma exceção aqui, dependendo de como deseja lidar com erros
    throw Exception('Falha ao criar documento de usuário ou meta inicial: $e');
  }
}

// Uso:
// Após o registro bem-sucedido do usuário
// User user = FirebaseAuth.instance.currentUser!;
// try {
//   await createUserDocument(
//     user,
//     'Nome do Usuário',
//     initialTotalSavings: 1000,
//     initialMonthlyBudget: 5000,
//     accountType: 'premium',
//   );
//   print('Usuário e meta inicial criados com sucesso');
// } catch (e) {
//   print('Erro ao criar usuário e meta inicial: $e');
//   // Trate o erro conforme necessário
// }