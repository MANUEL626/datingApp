import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importation nécessaire pour FilteringTextInputFormatter
import '../var.dart';
import 'home.dart';

class ForgottenMail extends StatefulWidget {
  const ForgottenMail({Key? key}) : super(key: key);

  @override
  State<ForgottenMail> createState() => _ForgottenMailState();
}

class _ForgottenMailState extends State<ForgottenMail> {
  final PageController _pageController = PageController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  int _currentPage = 0;
  String code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mot de passe oublié'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                // Page 1
                Container(
                  color: Colors.blue,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Adresse e-mail',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () async {
                                String mail = emailController.text;
                                if (mail.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Erreur"),
                                        content: Text('Veuillez saisir une adresse e-mail'),
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
                                } else {
                                  if (await _itemNameExists(mail)) {
                                    print('le compte existe');
                                    setState(() {
                                      code = '2021';
                                    });
                                    _pageController.nextPage(
                                      duration: Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Erreur"),
                                          content: Text('Adresse e-mail incorrecte'),
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
                                }
                              },
                              child: const Text('Envoyer'),
                            ),
                          ]
                      ),
                    ),
                  ),
                ),
                // Page 2
                Container(
                  color: Colors.green,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: codeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'CODE',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () async {
                                String _code = codeController.text;

                                if (_code == code) {
                                  setState(() {
                                    connect = true;
                                  });
                                  // Successful login
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomePage()),
                                  );
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Erreur"),
                                        content: const Text('Changer votre mot de passe'),
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
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Erreur"),
                                        content: const Text('Code incorrect'),
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
                              child: const Text('Envoyer'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                              child: const Text('Retour'),
                            ),
                          ]
                      ),
                    ),
                  ),
                ),
                // Page 3
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _itemNameExists(String name) async {
    final users = await dbHelper.getUsers();
    final user = await dbHelper.getUserMail(name);
    user_id = user[0]['user_id'];
    userInfo = user[0];
    return users.any((item) => item['mail'] == name);
  }
}
