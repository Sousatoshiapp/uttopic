import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uttopic/services/user_service.dart';
import 'package:uttopic/models/user.dart';

class MyIncomesScreen extends StatefulWidget {
  @override
  _MyIncomesScreenState createState() => _MyIncomesScreenState();
}

class _MyIncomesScreenState extends State<MyIncomesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _extraIncomeController = TextEditingController();
  final TextEditingController _investmentsController = TextEditingController();

  Map<String, TextEditingController> _customIncomes = {};

  double _totalIncomes = 0;

  @override
  void initState() {
    super.initState();
    _fetchSavedIncomes();
  }

  void _fetchSavedIncomes() async {
    final user = _auth.currentUser;
    if (user != null) {
      var userDoc = await _userService.getUser(user.uid);
      if (userDoc != null) {
        setState(() {
          _salaryController.text = userDoc.salary.toString();
          _extraIncomeController.text = userDoc.extraIncome.toString();
          _investmentsController.text = userDoc.investments.toString();

          userDoc.customIncomes.forEach((key, value) {
            _customIncomes[key] = TextEditingController(text: value.toString());
          });

          _updateTotalIncomes();
        });
      }
    }
  }

  void _updateTotalIncomes() {
    double total = 0;
    Map<String, double> incomes = {
      'salary': _parseDouble(_salaryController.text),
      'extraIncome': _parseDouble(_extraIncomeController.text),
      'investments': _parseDouble(_investmentsController.text),
    };

    _customIncomes.forEach((key, controller) {
      incomes[key] = _parseDouble(controller.text);
    });

    incomes.values.forEach((value) => total += value);

    setState(() {
      _totalIncomes = total;
    });

    _saveIncomes(incomes, total);
  }

  double _parseDouble(String value) {
    if (value.isEmpty) return 0;
    return double.tryParse(value) ?? 0;
  }

  void _saveIncomes(Map<String, double> incomes, double total) async {
    final user = _auth.currentUser;
    if (user != null) {
      incomes = incomes.map((key, value) => MapEntry(key, value.isFinite ? value : 0));
      incomes['totalIncomes'] = total.isFinite ? total : 0;
      await _userService.updateUserIncomes(user.uid, incomes);
      await _userService.updateUserTotalIncomes(user.uid, total);
    }
  }

  void _addCustomIncome() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newIncomeName = '';
        return AlertDialog(
          title: Text('Adicionar Nova Receita', style: TextStyle(color: Colors.white)),
          content: TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Nome da nova receita',
              hintStyle: TextStyle(color: Colors.white70),
            ),
            onChanged: (value) {
              newIncomeName = value;
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Adicionar'),
              onPressed: () {
                if (newIncomeName.isNotEmpty) {
                  setState(() {
                    _customIncomes[newIncomeName] = TextEditingController(text: '0');
                  });
                  _updateTotalIncomes();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
    );
  }

  void _deleteCustomIncome(String incomeName) {
    setState(() {
      _customIncomes.remove(incomeName);
    });
    _updateTotalIncomes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Minhas Receitas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total de Receitas: R\$ ${_totalIncomes.toStringAsFixed(2)}',
              style: TextStyle(color: Color(0xFFADFF2F), fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildIncomeCard('Salário', _salaryController),
                  _buildIncomeCard('Renda Extra', _extraIncomeController),
                  _buildIncomeCard('Aplicações', _investmentsController),
                  ..._customIncomes.entries.map((entry) => _buildCustomIncomeCard(entry.key, entry.value)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addCustomIncome,
                    child: Text('Adicionar Nova Receita'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFADFF2F),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeCard(String title, TextEditingController controller) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            TextField(
              controller: controller,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Insira o valor',
                hintStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFADFF2F)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFADFF2F), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _updateTotalIncomes();
              },
            ),
            SizedBox(height: 8),
            Text(
              _totalIncomes > 0
                  ? 'Percentual: ${((_parseDouble(controller.text) / _totalIncomes) * 100).toStringAsFixed(2)}%'
                  : 'Percentual: 0%',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomIncomeCard(String title, TextEditingController controller) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCustomIncome(title),
                ),
              ],
            ),
            SizedBox(height: 8),
            TextField(
              controller: controller,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Insira o valor',
                hintStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFADFF2F)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFADFF2F), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                _updateTotalIncomes();
              },
            ),
            SizedBox(height: 8),
            Text(
              _totalIncomes > 0
                  ? 'Percentual: ${((_parseDouble(controller.text) / _totalIncomes) * 100).toStringAsFixed(2)}%'
                  : 'Percentual: 0%',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}