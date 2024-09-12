import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLogin = true;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          await _signIn();
        } else {
          await _register();
        }
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        _showErrorDialog('Erro de Autenticação', _getErrorMessage(e));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signIn() async {
    await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Future<void> _register() async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    // Aqui você pode adicionar lógica adicional para salvar dados do usuário no Firestore
    // Por exemplo:
    // await FirestoreService().createUser(userCredential.user!.uid, _emailController.text);
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Nenhum usuário encontrado com este email.';
        case 'wrong-password':
          return 'Senha incorreta.';
        case 'email-already-in-use':
          return 'Este email já está em uso.';
        default:
          return 'Ocorreu um erro na autenticação.';
      }
    }
    return error.toString();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Registro')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor, insira um email válido.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              if (_isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(_isLogin ? 'Login' : 'Registrar'),
                ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin ? 'Criar uma conta' : 'Já tenho uma conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}