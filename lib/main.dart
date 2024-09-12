import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uttopic/screens/home_screen.dart';
import 'package:uttopic/screens/goals_screen.dart';
import 'package:uttopic/screens/groups_screen.dart';
import 'package:uttopic/screens/profile_screen.dart';
import 'package:uttopic/screens/register_screen.dart';
import 'package:uttopic/screens/login_screen.dart';
import 'package:uttopic/screens/my_expenses_screen.dart';
import 'package:uttopic/screens/my_incomes_screen.dart';
import 'package:uttopic/screens/my_balance_screen.dart'; // Nova importação
import 'package:uttopic/theme/app_theme.dart';
import 'package:uttopic/widgets/uttopic_logo.dart';
import 'package:uttopic/services/goal_service.dart';
import 'package:uttopic/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCYMEskPD0Zj339EQh26VsWyzwFn3F3_So",
        authDomain: "uttopic-afe89.firebaseapp.com",
        projectId: "uttopic-afe89",
        storageBucket: "uttopic-afe89.appspot.com",
        messagingSenderId: "525790428461",
        appId: "1:525790428461:web:afd581642aebe5e31d27a4",
        measurementId: "G-58SSDFHS9Y"
      ),
    );
    print("Firebase inicializado com sucesso!");
  } catch (e) {
    print("Erro ao inicializar Firebase: $e");
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uttopic',
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthWrapper(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => MainScreen(),
        '/goals': (context) => GoalsScreen(),
        '/groups': (context) => GroupsScreen(),
        '/profile': (context) => ProfileScreen(),
        '/expenses': (context) => MyExpensesScreen(),
        '/incomes': (context) => MyIncomesScreen(),
        '/balance': (context) => MyBalanceScreen(), // Nova rota
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)));
        }
        if (snapshot.hasData) {
          return MainScreen();
        }
        return LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    GoalsScreen(),
    GroupsScreen(),
    MyBalanceScreen(), // Nova tela de Meu Saldo
    MyIncomesScreen(),
    MyExpensesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UttopicLogo(size: 40),
                  IconButton(
                    icon: Icon(Icons.bug_report, color: AppTheme.textColor),
                    onPressed: _runTests,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet), // Novo ícone para Meu Saldo
            label: 'Meu Saldo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Receitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_down),
            label: 'Despesas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textColor.withOpacity(0.5),
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  void _runTests() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("Autenticado anonimamente: ${userCredential.user?.uid}");
    } catch (e) {
      print("Erro de autenticação: $e");
    }

    try {
      await FirebaseFirestore.instance.collection('testes').add({
        'mensagem': 'Teste de escrita',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Dado escrito com sucesso!");

      final snapshot = await FirebaseFirestore.instance.collection('testes').get();
      for (var doc in snapshot.docs) {
        print("Documento lido: ${doc.data()}");
      }
    } catch (e) {
      print("Erro no Firestore: $e");
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resultados dos Testes'),
          content: Text('Verifique o console para ver os resultados detalhados.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}