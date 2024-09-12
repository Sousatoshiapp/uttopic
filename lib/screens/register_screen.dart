import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uttopic/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Cadastro', style: TextStyle(color: AppTheme.textColor)),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: AppTheme.textColor),
                ),
                style: TextStyle(color: AppTheme.textColor),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: AppTheme.textColor),
                ),
                style: TextStyle(color: AppTheme.textColor),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: AppTheme.textColor),
                ),
                style: TextStyle(color: AppTheme.textColor),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Senha',
                  labelStyle: TextStyle(color: AppTheme.textColor),
                ),
                style: TextStyle(color: AppTheme.textColor),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: _isLoading
                    ? CircularProgressIndicator(color: AppTheme.backgroundColor)
                    : Text('Cadastrar'),
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.backgroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Criar usuário no Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Salvar informações adicionais no Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Redirecionar para a tela principal
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no cadastro: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}