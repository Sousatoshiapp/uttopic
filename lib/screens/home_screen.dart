import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:uttopic/models/user.dart';
import 'package:uttopic/models/financial_goal.dart';
import 'package:uttopic/models/transaction.dart' as TransactionModel;
import 'package:uttopic/models/bank_account.dart';
import 'package:uttopic/services/goal_service.dart';
import 'package:uttopic/services/user_service.dart';
import 'package:uttopic/screens/my_expenses_screen.dart';
import 'package:uttopic/screens/my_incomes_screen.dart';
import 'package:uttopic/screens/my_balance_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  final GoalService _goalService = GoalService();
  final FirebaseAuth.FirebaseAuth _auth = FirebaseAuth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Image.asset('assets/images/uttopic_logo.png', height: 150),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_auth.currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFADFF2F)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Usuário não encontrado', style: TextStyle(color: Colors.white)));
          }

          User user = User.fromFirestore(snapshot.data!);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            color: Color(0xFFADFF2F),
            backgroundColor: Colors.black,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(user),
                    SizedBox(height: 24),
                    _buildBalanceCard(user),
                    SizedBox(height: 24),
                    _buildGoalsSection(),
                    SizedBox(height: 24),
                    _buildRecentActivities(user),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: Icon(Icons.add, color: Colors.black),
        backgroundColor: Color(0xFFADFF2F),
      ),
    );
  }

  Widget _buildWelcomeSection(User user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: user.profilePicUrl.isNotEmpty
              ? NetworkImage(user.profilePicUrl)
              : null,
          child: user.profilePicUrl.isEmpty
              ? Icon(Icons.person, size: 30, color: Colors.white)
              : null,
          backgroundColor: Colors.grey[800],
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${user.name}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Bem-vindo de volta',
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(User user) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyBalanceScreen()),
        );
      },
      child: Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xFFADFF2F), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'R\$ ${user.balance.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFADFF2F)),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBalanceItem(
                    'Receitas', 
                    'R\$ ${user.totalIncomes.toStringAsFixed(2)}', 
                    Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyIncomesScreen()),
                      );
                    }
                  ),
                  _buildBalanceItem(
                    'Despesas', 
                    'R\$ ${user.totalExpenses.toStringAsFixed(2)}', 
                    Colors.red, 
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyExpensesScreen()),
                      );
                    }
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String title, String amount, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
          SizedBox(height: 4),
          Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildGoalsSection() {
    return StreamBuilder<List<FinancialGoal>>(
      stream: _goalService.getUserGoals(_auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError) {
          print('Erro ao carregar metas: ${snapshot.error}');
          return Center(child: Text('Erro ao carregar metas', style: TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Nenhuma meta encontrada', style: TextStyle(color: Colors.white)));
        }

        List<FinancialGoal> goals = snapshot.data!;
        print('Número de metas carregadas: ${goals.length}');
        goals.forEach((goal) => print('Meta: $goal'));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metas Ativas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 16),
            ...goals.map((goal) => _buildGoalCard(context, goal)),
          ],
        );
      },
    );
  }

  Widget _buildGoalCard(BuildContext context, FinancialGoal goal) {
    return GestureDetector(
      onTap: () => _showAddProgressDialog(context, goal),
      child: Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Color(0xFFADFF2F).withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goal.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFADFF2F)),
              ),
              SizedBox(height: 4),
              Text(
                'Meta: R\$ ${goal.targetAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
              ),
              Text(
                'Progresso: R\$ ${goal.currentAmount.toStringAsFixed(2)} (${(goal.progress * 100).toStringAsFixed(1)}%)',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProgressDialog(BuildContext context, FinancialGoal goal) {
    TextEditingController _amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Adicionar Progresso', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Valor',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Adicionar', style: TextStyle(color: Color(0xFFADFF2F))),
              onPressed: () {
                double amount = double.tryParse(_amountController.text) ?? 0;
                print('Valor inserido: $amount');
                if (amount > 0) {
                  print('Atualizando meta ${goal.id} com valor $amount');
                  _updateGoalProgress(dialogContext, goal.id, amount);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
    );
  }

  Future<void> _updateGoalProgress(BuildContext context, String goalId, double amount) async {
    try {
      await _goalService.updateGoalProgress(goalId, amount);
      print('Meta atualizada com sucesso');
      
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Progresso da meta atualizado com sucesso!'),
            backgroundColor: Color(0xFFADFF2F),
          ),
        );
      }
    } catch (e) {
      print('Erro ao atualizar meta: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar progresso da meta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildRecentActivities(User user) {
    List<TransactionModel.Transaction> recentTransactions = List<TransactionModel.Transaction>.from(user.transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    recentTransactions = recentTransactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Atividades Recentes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 16),
        ...recentTransactions.map((transaction) => _buildActivityItem(transaction)),
      ],
    );
  }

  Widget _buildActivityItem(TransactionModel.Transaction transaction) {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Color(0xFFADFF2F).withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        leading: Icon(
          transaction.amount > 0 ? Icons.arrow_upward : Icons.arrow_downward,
          color: transaction.amount > 0 ? Colors.green : Colors.red,
        ),
        title: Text(transaction.description, style: TextStyle(color: Colors.white)),
        trailing: Text(
          'R\$ ${transaction.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: transaction.amount > 0 ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    TextEditingController _descriptionController = TextEditingController();
    TextEditingController _amountController = TextEditingController();
    bool _isExpense = false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Adicionar Transação', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Valor',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  Row(
                    children: [
                      Text('É uma despesa?', style: TextStyle(color: Colors.white)),
                      Switch(
                        value: _isExpense,
                        onChanged: (value) {
                          setState(() {
                            _isExpense = value;
                          });
                        },
                        activeColor: Color(0xFFADFF2F),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: Text('Adicionar', style: TextStyle(color: Color(0xFFADFF2F))),
                  onPressed: () {
                    double amount = double.tryParse(_amountController.text) ?? 0;
                    if (_isExpense) amount = -amount;
                    _addTransaction(
                      dialogContext,
                      _descriptionController.text,
                      amount,
                    );
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
              backgroundColor: Colors.black,
            );
          },
        );
      },
    );
  }

  Future<void> _addTransaction(BuildContext context, String description, double amount) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final transactionData = {
          'description': description,
          'amount': amount,
          'date': FieldValue.serverTimestamp(),
        };

        await _firestore.runTransaction((transaction) async {
          DocumentReference userRef = _firestore.collection('users').doc(user.uid);
          DocumentSnapshot userSnapshot = await transaction.get(userRef);
          
          if (userSnapshot.exists) {
            Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
            double currentBalance = (userData['balance'] ?? 0).toDouble();
            double newBalance = currentBalance + amount;
            
            List<dynamic> currentTransactions = userData['transactions'] ?? [];
            currentTransactions.add(transactionData);
            
            transaction.update(userRef, {
              'balance': newBalance,
              'transactions': currentTransactions,
            });
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transação adicionada com sucesso!'),
            backgroundColor: Color(0xFFADFF2F),
          ),
        );
      }
    } catch (e) {
      print('Erro ao adicionar transação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar transação. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditFinancialDataDialog(User user) {
    TextEditingController balanceController = TextEditingController(text: user.balance.toString());
    TextEditingController incomeController = TextEditingController(text: user.totalIncomes.toString());
    TextEditingController expensesController = TextEditingController(text: user.totalExpenses.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Dados Financeiros', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Saldo Total'),
                style: TextStyle(color: Colors.white),
              ),
              TextField(
                controller: incomeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Receitas'),
                style: TextStyle(color: Colors.white),
              ),
              TextField(
                controller: expensesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Despesas'),
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () {
                _updateFinancialData(
                  double.parse(balanceController.text),
                  double.parse(incomeController.text),
                  double.parse(expensesController.text),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
    );
  }

  void _updateFinancialData(double balance, double income, double expenses) async {
    try {
      await _userService.updateUserFinancialData(_auth.currentUser!.uid, balance, income, expenses);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dados financeiros atualizados com sucesso!')),
      );
    } catch (e) {
      print('Erro ao atualizar dados financeiros: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar dados financeiros')),
      );
    }
  }
}