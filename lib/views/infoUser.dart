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
                      onPressed: (){},
                      icon: const Icon(Icons.output),
                    color: Colors.red,


                  ),
                  const  SizedBox(width: 32),
                  IconButton(
                      onPressed: (){},
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
}
