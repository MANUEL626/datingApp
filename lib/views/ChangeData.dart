import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../var.dart';

class UsernamePage extends StatelessWidget {
  UsernamePage({super.key});
  final TextEditingController usernameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Username'),
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (await _itemNameExists(usernameController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ce nom d\'utilisateur est déjà pris.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else{
                  dbHelper.updateUserUsername(user_id, usernameController.text);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Username modifié avec succès!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Se connecter'),
            ),
          ]
          )
        )
      ),
    );
  }
  Future<bool> _itemNameExists(String name) async {
    final users = await dbHelper.getUsers();
    return users.any((item) => item['username'] == name);
  }

  String? validateUsername(String? value) {
    if (value == null ||
        value.isEmpty ||
        value.length < 3 ||
        value.contains(' ')) { // Vérifier la présence d'espaces
      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères et ne doit pas contenir d\'espace';
    }
    return null;
  }
}

class EmailPage extends StatelessWidget {
  EmailPage({super.key});
  final TextEditingController emailController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email'),
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')), // Exclure les espaces
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (await _itemMailExists(emailController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cet e-mail est déjà associé à un compte.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else{
                          dbHelper.updateUserMail(user_id, emailController.text);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('E-mail modifié avec succès!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const Text('Se connecter'),
                    ),
                  ]
              )
          )
      ),
    );
  }
  Future<bool> _itemMailExists(String email) async {
    final users = await dbHelper.getUsers();
    return users.any((item) => item['mail'] == email);
  }

  String? validateEmail(String? value) {
    if (value == null ||
        value.isEmpty ||
        !value.contains('@') ||
        !value.contains('.')) {
      return 'Veuillez entrer une adresse e-mail valide';
    }
    return null;
  }
}

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Username'),
      ),
      body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        suffixIcon: IconButton(
                          icon: Icon(showPassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) => validatePassword(value),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !showConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                        suffixIcon: IconButton(
                          icon: Icon(showConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value != passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () async {
                        dbHelper.updateUserPassword(user_id, passwordController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mot de passe modifié avec succès!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text('Se connecter'),
                    ),
                  ]
              )
          )
      ),
    );
  }
  String? validatePassword(String? value) {
    if (value == null ||
        value.isEmpty ||
        value.length < 7 ||
        value.contains(' ')) { // Vérifier la présence d'espaces
      return 'Le mot de passe doit contenir au moins 7 caractères et ne doit pas contenir d\'espace';
    }
    return null;
  }
}


class ChangeProfilePage extends StatefulWidget {
  const ChangeProfilePage({Key? key}) : super(key: key);

  @override
  _ChangeProfilePageState createState() => _ChangeProfilePageState();
}

class _ChangeProfilePageState extends State<ChangeProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String text = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POST'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showImageSourceDialog,
              child: const Text('Sélectionner une image'),
            ),
            _selectedImage != null
                ? Image.file(_selectedImage!)
                : Column(
              children: [
                Text(
                  text,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 10),
              ],
            ),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une source d\'image'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text('Appareil photo'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text('Galerie'),
          ),
        ],
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    final pickedImage = await _imagePicker.pickImage(source: source);

    setState(() {
      if (pickedImage != null) {
        _selectedImage = File(pickedImage.path);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_selectedImage == null) {
      setState(() {
        text = 'Veuillez choisir une image';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir une image.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    else{
      await dbHelper.updateUserProfile(user_id, _selectedImage != null ? _selectedImage!.path : '');
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Élément enregistré avec succès!'),
          duration: Duration(seconds: 2),
        ),
      );

    }

  }
}
