import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uttopic/screens/register_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String _username = '';
  String _email = '';
  String _profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        var userData = await _firestore.collection('users').doc(user.uid).get();
        setState(() {
          _username = userData.data()?['name'] ?? 'Usuário';
          _email = user.email ?? 'Sem email';
          _profileImageUrl = userData.data()?['profilePicUrl'] ?? '';
        });
      } catch (e) {
        print('Erro ao carregar dados do usuário: $e');
      }
    }
  }

  Future<void> _updateProfileImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      User? user = _auth.currentUser;

      if (user != null) {
        try {
          // Upload da imagem para o Firebase Storage
          TaskSnapshot uploadTask = await _storage
              .ref('profile_images/${user.uid}.jpg')
              .putFile(file);

          // Obter a URL da imagem carregada
          String downloadUrl = await uploadTask.ref.getDownloadURL();

          // Atualizar o Firestore com a nova URL da imagem
          await _firestore.collection('users').doc(user.uid).update({
            'profilePicUrl': downloadUrl,
          });

          setState(() {
            _profileImageUrl = downloadUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Foto de perfil atualizada com sucesso!')),
          );
        } catch (e) {
          print('Erro ao atualizar a foto de perfil: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar a foto de perfil')),
          );
        }
      }
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _updateProfileImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : null,
                child: _profileImageUrl.isEmpty
                    ? Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 10),
            Text('Toque para editar', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 20),
            Text(_username, style: TextStyle(fontSize: 24, color: Colors.white)),
            Text(_email, style: TextStyle(fontSize: 16, color: Colors.white)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signOut,
              child: Text('Sair'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFADFF2F),
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}