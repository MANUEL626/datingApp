import 'dart:io';
import 'package:dating_app/var.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String text = '';
  late final post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POST'),
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
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 10),
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
      post = {
        'user_id' : user_id,
        'post' : _selectedImage != null ? _selectedImage!.path : '',
      };

      await dbHelper.insertPost(post);
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
