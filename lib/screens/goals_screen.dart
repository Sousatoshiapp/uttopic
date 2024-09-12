import 'package:flutter/material.dart';
import 'package:uttopic/models/financial_goal.dart';
import 'package:uttopic/services/goal_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final GoalService _goalService = GoalService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Minhas Metas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<FinancialGoal>>(
        stream: _goalService.getUserGoals(_auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Color(0xFFADFF2F)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma meta encontrada', style: TextStyle(color: Colors.white)));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              FinancialGoal goal = snapshot.data![index];
              return _buildGoalCard(goal);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFADFF2F),
        onPressed: () => _showAddGoalDialog(),
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildGoalCard(FinancialGoal goal) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(goal.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(
          'R\$ ${goal.currentAmount.toStringAsFixed(2)} / R\$ ${goal.targetAmount.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFFADFF2F)),
              onPressed: () => _showEditGoalDialog(goal),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Color(0xFFADFF2F)),
              onPressed: () => _showDeleteGoalDialog(goal),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController targetAmountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Adicionar Nova Meta', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Título da Meta',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADFF2F)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADFF2F), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: targetAmountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Valor Alvo',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADFF2F)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADFF2F), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Color(0xFFADFF2F))),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Adicionar', style: TextStyle(color: Color(0xFFADFF2F))),
              onPressed: () {
                _addGoal(titleController.text, double.parse(targetAmountController.text));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditGoalDialog(FinancialGoal goal) {
    TextEditingController titleController = TextEditingController(text: goal.title);
    TextEditingController targetAmountController = TextEditingController(text: goal.targetAmount.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Editar Meta', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Título da Meta',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADFF2F)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADFF2F), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: targetAmountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Valor Alvo',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADFF2F)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFADFF2F), width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Color(0xFFADFF2F))),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Salvar', style: TextStyle(color: Color(0xFFADFF2F))),
              onPressed: () {
                _editGoal(goal.id, titleController.text, double.parse(targetAmountController.text));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteGoalDialog(FinancialGoal goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Excluir Meta', style: TextStyle(color: Colors.white)),
          content: Text('Tem certeza que deseja excluir esta meta?', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Color(0xFFADFF2F))),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Excluir', style: TextStyle(color: Color(0xFFADFF2F))),
              onPressed: () {
                _deleteGoal(goal.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addGoal(String title, double targetAmount) async {
    try {
      await _goalService.addGoal(FinancialGoal(
        id: '',
        title: title,
        targetAmount: targetAmount,
        userId: _auth.currentUser!.uid,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meta adicionada com sucesso!', style: TextStyle(color: Colors.white))),
      );
    } catch (e) {
      print('Erro ao adicionar meta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar meta', style: TextStyle(color: Colors.white))),
      );
    }
  }

  void _editGoal(String goalId, String title, double targetAmount) async {
    try {
      await _goalService.updateGoal(goalId, title, targetAmount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meta atualizada com sucesso!', style: TextStyle(color: Colors.white))),
      );
    } catch (e) {
      print('Erro ao atualizar meta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar meta', style: TextStyle(color: Colors.white))),
      );
    }
  }

  void _deleteGoal(String goalId) async {
    try {
      await _goalService.deleteGoal(goalId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meta excluída com sucesso!', style: TextStyle(color: Colors.white))),
      );
    } catch (e) {
      print('Erro ao excluir meta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir meta', style: TextStyle(color: Colors.white))),
      );
    }
  }
}
