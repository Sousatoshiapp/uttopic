import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uttopic/models/bank_account.dart';
import 'package:uttopic/services/user_service.dart';

class MyBalanceScreen extends StatefulWidget {
  @override
  _MyBalanceScreenState createState() => _MyBalanceScreenState();
}

class _MyBalanceScreenState extends State<MyBalanceScreen> {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<BankAccount> _bankAccounts = [];
  double _totalBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
  }

  Future<void> _loadBankAccounts() async {
    String userId = _auth.currentUser!.uid;
    var accounts = await _userService.getBankAccounts(userId);
    setState(() {
      _bankAccounts = accounts;
      _calculateTotalBalance();
    });
  }

  void _calculateTotalBalance() {
    _totalBalance = _bankAccounts.fold(0, (sum, account) => sum + account.balance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Meu Saldo', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Saldo Total: R\$ ${_totalBalance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFADFF2F)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _bankAccounts.length,
              itemBuilder: (context, index) {
                return _buildBankAccountCard(_bankAccounts[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBankAccountDialog(),
        child: Icon(Icons.add, color: Colors.black),
        backgroundColor: Color(0xFFADFF2F),
      ),
    );
  }

  Widget _buildBankAccountCard(BankAccount account) {
    double percentage = (_totalBalance > 0) ? (account.balance / _totalBalance) * 100 : 0;
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[900],
      child: ListTile(
        leading: Image.network(account.bankLogo, width: 40, height: 40),
        title: Text(account.bankName, style: TextStyle(color: Colors.white)),
        subtitle: Text('R\$ ${account.balance.toStringAsFixed(2)}', style: TextStyle(color: Color(0xFFADFF2F))),
        trailing: Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(color: Colors.white)),
        onTap: () => _showEditBankAccountDialog(account),
      ),
    );
  }

  void _showAddBankAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedBank = '';
        double balance = 0;

        return AlertDialog(
          title: Text('Adicionar Conta Bancária', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: Text('Selecione o Banco', style: TextStyle(color: Colors.white)),
                value: selectedBank.isEmpty ? null : selectedBank,
                items: brazilianBanks.map((String bank) {
                  return DropdownMenuItem<String>(
                    value: bank,
                    child: Text(bank, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBank = newValue!;
                  });
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Saldo', labelStyle: TextStyle(color: Colors.white)),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  balance = double.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Adicionar'),
              onPressed: () {
                if (selectedBank.isNotEmpty && balance > 0) {
                  _addBankAccount(selectedBank, balance);
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

  void _showEditBankAccountDialog(BankAccount account) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double newBalance = account.balance;

        return AlertDialog(
          title: Text('Editar Conta Bancária', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(account.bankName, style: TextStyle(color: Colors.white, fontSize: 18)),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Novo Saldo', labelStyle: TextStyle(color: Colors.white)),
                style: TextStyle(color: Colors.white),
                controller: TextEditingController(text: account.balance.toString()),
                onChanged: (value) {
                  newBalance = double.tryParse(value) ?? account.balance;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Atualizar'),
              onPressed: () {
                _updateBankAccount(account.id, newBalance);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteBankAccount(account.id);
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.black,
        );
      },
    );
  }

  void _addBankAccount(String bankName, double balance) async {
    String userId = _auth.currentUser!.uid;
    await _userService.addBankAccount(userId, bankName, balance);
    _loadBankAccounts();
  }

  void _updateBankAccount(String accountId, double newBalance) async {
    String userId = _auth.currentUser!.uid;
    await _userService.updateBankAccount(userId, accountId, newBalance);
    _loadBankAccounts();
  }

  void _deleteBankAccount(String accountId) async {
    String userId = _auth.currentUser!.uid;
    await _userService.deleteBankAccount(userId, accountId);
    _loadBankAccounts();
  }
}

// Lista de bancos brasileiros (você pode expandir esta lista conforme necessário)
const List<String> brazilianBanks = [
  'Banco do Brasil', 'Caixa Econômica Federal', 'Bradesco', 'Itaú', 'Santander',
  'Nubank', 'Inter', 'Banco Original', 'C6 Bank', 'Next'
];