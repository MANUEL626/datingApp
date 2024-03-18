import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../var.dart';
import 'forgottenMail.dart';
import 'home.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  var users;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: SingleChildScrollView( // Utilise un SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')), // Exclure les espaces
                ],
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')), // Exclure les espaces
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  // Ajoutez votre logique de connexion ici
                  String username = usernameController.text;
                  String password = passwordController.text;

                  // Attendre la validation avant de passer à l'étape suivante
                  if (await valider(username, password)) {
                    setState(() {
                      connect = true;
                    });
                    // Successful login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }
                  else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Erreur"),
                          content: Text('Identifiant incorrect'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'OK',
                                style: TextStyle(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Se connecter'),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationPage(),
                        ),
                      );
                    },
                    child: const Text('S\'inscrire'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgottenMail(),
                        ),
                      );
                    },
                    child: const Text('E-mail oublié'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> valider(String username, String password) async {
    users = await dbHelper.getUsers();
    final user = await dbHelper.getUser(username);
    if (user != null && user.isNotEmpty) {
      if (user[0]['password'] == password) {
        user_id = user[0]['user_id'];
        userInfo = user[0];
        return true;
      }
    }
    return false;
  }
}

