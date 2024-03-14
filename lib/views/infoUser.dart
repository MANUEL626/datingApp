import 'dart:io';

import 'package:dating_app/views/profilePage.dart';
import 'package:flutter/material.dart';

import '../var.dart';
import 'home.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user['username']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(File(user['profile'])),
              ),
              const SizedBox(height: 16),
              Text(
                user['username'],
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold
                ) ,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(user: user),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person)
                  ),
                  const  SizedBox(width: 32),
                  IconButton(
                      onPressed: (){
                        _showConfirmationDialog(
                          context,
                          'Quit chat',
                          'Êtes-vous sûr de vouloir quitter le chat?',
                              () async {
                            await dbHelper.removeFriendship(user_id, user['user_id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Vous venez de quitter le chat de "${user['user_id']}"!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()),
                            );
                          }, // Action pour quitter le chat
                        );
                      },
                      icon: const Icon(Icons.output),
                    color: Colors.red,


                  ),
                  const  SizedBox(width: 32),
                  IconButton(
                      onPressed: (){
                        _showConfirmationDialog(
                          context,
                          'Signal',
                          'Êtes-vous sûr de vouloir signaler?',
                              () async {
                            await dbHelper.removeFriendship(user_id, user['user_id']);
                            await dbHelper.reportUser(user_id, user['user_id']);
                            SnackBar(
                              content: Text('Vous venez de signaler l\'utilisateur "${user['user_id']}"!'),
                              duration: Duration(seconds: 2),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage()),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.block),
                      color: Colors.red,
                  ),
                  const  SizedBox(width: 32),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  // Fonction pour afficher une alerte de confirmation
  void _showConfirmationDialog(
      BuildContext context,
      String title,
      String content,
      Function() onConfirm,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm(); // Exécutez la fonction onConfirm si l'utilisateur confirme
              },
              child: Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}
