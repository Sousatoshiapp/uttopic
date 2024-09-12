import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupsScreen extends StatefulWidget {
  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _groupNameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createGroup() async {
    if (_groupNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira um nome para o grupo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('groups').add({
          'name': _groupNameController.text,
          'createdBy': user.uid,
          'members': [user.uid],
          'createdAt': FieldValue.serverTimestamp(),
        });
        _groupNameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Grupo criado com sucesso!')),
        );
      } else {
        throw Exception('Usuário não autenticado');
      }
    } catch (e) {
      print('Erro ao criar grupo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar grupo. Por favor, tente novamente.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Grupos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _groupNameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nome do Grupo',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFADFF2F)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFADFF2F), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: Color(0xFFADFF2F)),
                  onPressed: _isLoading ? null : _createGroup,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .where('members', arrayContains: _auth.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFFADFF2F)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar grupos: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Nenhum grupo encontrado.', style: TextStyle(color: Colors.white)));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(data['name'] ?? 'Grupo sem nome', 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('Membros: ${(data['members'] as List).length}', 
                          style: TextStyle(color: Colors.white70)),
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFFADFF2F),
                          child: Text((data['name'] as String)[0].toUpperCase(), 
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFFADFF2F)),
                        onTap: () {
                          // Navegue para a tela de detalhes do grupo
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }
}