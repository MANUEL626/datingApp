import 'package:flutter/material.dart';
import '../var.dart';
import 'login.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'starting.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String text = '';

  bool showPassword = false;
  bool showConfirmPassword = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
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
                  validator: (value) => validateEmail(value),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                  ),
                  validator: (value) => validateUsername(value),
                ),
                const SizedBox(height: 16.0),
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
                const SizedBox(height: 16.0),
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
                  onPressed: _showImageSourceDialog,
                  child: Text('Sélectionner une image'),
                ),
                _selectedImage != null
                    ? Image.file(_selectedImage!)
                    : Column(
                  children: [
                    Text(
                      text,
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _registerUser,
                  child: const Text('S\'inscrire'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      String email = emailController.text;
      String username = usernameController.text;
      String password = passwordController.text;
      try {
        if (await _itemMailExists(email)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cet e-mail est déjà associé à un compte.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (await _itemNameExists(username)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ce nom d\'utilisateur est déjà pris.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          await dbHelper.insertUser({
            'username': username,
            'mail': email,
            'password': password,
            'profile': _selectedImage != null ? _selectedImage!.path : '',
          });
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        print('Error registering user: $e');
        // Handle error appropriately
      }
    }
  }

  Future<bool> _itemMailExists(String email) async {
    final users = await dbHelper.getUsers();
    return users.any((item) => item['mail'] == email);
  }

  Future<bool> _itemNameExists(String name) async {
    final users = await dbHelper.getUsers();
    return users.any((item) => item['username'] == name);
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

  String? validateUsername(String? value) {
    if (value == null ||
        value.isEmpty ||
        value.length < 3 ||
        value.contains(' ')) { // Vérifier la présence d'espaces
      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères et ne doit pas contenir d\'espace';
    }
    return null;
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

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir une source d\'image'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: Text('Appareil photo'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: Text('Galerie'),
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
}
