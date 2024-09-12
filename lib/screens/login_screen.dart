import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uttopic/theme/app_theme.dart';
import 'package:uttopic/services/database_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (!mounted) return;
      
      // Verificar e criar metas se necessário
      await DatabaseService.verifyGoalsCollection();
      
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Login', style: TextStyle(color: AppTheme.textColor)),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: AppTheme.textColor),
              ),
              style: TextStyle(color: AppTheme.textColor),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: AppTheme.textColor),
              ),
              style: TextStyle(color: AppTheme.textColor),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              child: _isLoading
                  ? CircularProgressIndicator(color: AppTheme.backgroundColor)
                  : Text('Entrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.backgroundColor,
             ),
           ),
            TextButton(
              child: Text(
                'Não tem uma conta? Registre-se',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              },
            ),
          ],
        ),
      ),
    );
  }
}