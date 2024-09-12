import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uttopic/services/user_service.dart';

class MyExpensesScreen extends StatefulWidget {
  @override
  _MyExpensesScreenState createState() => _MyExpensesScreenState();
}

class _MyExpensesScreenState extends State<MyExpensesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _housingController = TextEditingController();
  final TextEditingController _creditCardController = TextEditingController();
  final TextEditingController _mobilityController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _utilitiesController = TextEditingController();
  final TextEditingController _electricityController = TextEditingController();
  final TextEditingController _entertainmentController = TextEditingController();
  final TextEditingController _onlineShoppingController = TextEditingController();
  final TextEditingController _financingController = TextEditingController();

  double _totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    _fetchSavedExpenses();
  }

  void _fetchSavedExpenses() async {
    final user = _auth.currentUser;
    if (user != null) {
      var userDoc = await _userService.getUser(user.uid);
      if (userDoc != null) {
        setState(() {
          _rentController.text = userDoc.rent.toString();
          _housingController.text = userDoc.housing.toString();
          _creditCardController.text = userDoc.creditCard.toString();
          _mobilityController.text = userDoc.mobility.toString();
          _foodController.text = userDoc.food.toString();
          _utilitiesController.text = userDoc.utilities.toString();
          _electricityController.text = userDoc.electricity.toString();
          _entertainmentController.text = userDoc.entertainment.toString();
          _onlineShoppingController.text = userDoc.onlineShopping.toString();
          _financingController.text = userDoc.financing.toString();

          _updateTotalExpenses();
        });
      }
    }
  }

  void _updateTotalExpenses() {
    double total = 0;
    Map<String, double> expenses = {
      'rent': _parseDouble(_rentController.text),
      'housing': _parseDouble(_housingController.text),
      'creditCard': _parseDouble(_creditCardController.text),
      'mobility': _parseDouble(_mobilityController.text),
      'food': _parseDouble(_foodController.text),
      'utilities': _parseDouble(_utilitiesController.text),
      'electricity': _parseDouble(_electricityController.text),
      'entertainment': _parseDouble(_entertainmentController.text),
      'onlineShopping': _parseDouble(_onlineShoppingController.text),
      'financing': _parseDouble(_financingController.text),
    };

    expenses.values.forEach((value) => total += value);

    setState(() {
      _totalExpenses = total;
    });

    _saveExpenses(expenses, total);
  }

  double _parseDouble(String value) {
    if (value.isEmpty) return 0;
    return double.tryParse(value) ?? 0;
  }

  void _saveExpenses(Map<String, double> expenses, double total) async {
    final user = _auth.currentUser;
    if (user != null) {
      expenses = expenses.map((key, value) => MapEntry(key, value.isFinite ? value : 0));
      expenses['totalExpenses'] = total.isFinite ? total : 0;
      await _userService.updateUserExpenses(user.uid, expenses);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Minhas Despesas', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total de Despesas: R\$ ${_totalExpenses.toStringAsFixed(2)}',
              style: TextStyle(color: Color(0xFFADFF2F), fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildExpenseCard('Meu aluguel', _rentController),
                  _buildExpenseCard('Despesas com moradia (condomínio, IPTU, etc.)', _housingController),
                  _buildExpenseCard('Cartão de crédito', _creditCardController),
                  _buildExpenseCard('Mobilidade (taxi, Uber, etc.)', _mobilityController),
                  _buildExpenseCard('Alimentação', _foodController),
                  _buildExpenseCard('Conta de celular, internet, etc.', _utilitiesController),
                  _buildExpenseCard('Conta de luz', _electricityController),
                  _buildExpenseCard('Diversão', _entertainmentController),
                  _buildExpenseCard('Compras online', _onlineShoppingController),
                  _buildExpenseCard('Financiamentos', _financingController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(String title, TextEditingController controller) {
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
                _updateTotalExpenses();
              },
            ),
            SizedBox(height: 8),
            Text(
              _totalExpenses > 0
                  ? 'Percentual: ${((_parseDouble(controller.text) / _totalExpenses) * 100).toStringAsFixed(2)}%'
                  : 'Percentual: 0%',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}