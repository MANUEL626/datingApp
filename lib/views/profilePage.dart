import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../var.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});
  final Map<String, dynamic> user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int friendNumber = 0;
  int postNumber = 0;
  int signalNumber =0;
  List<Map<String, dynamic>> posts = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final loadedFriendNumber = await dbHelper.getFriendCount(widget.user['user_id']);
    final loadedPostNumber = await dbHelper.getPostCount(widget.user['user_id']);
    final loadedSignalNumber = await dbHelper.getSignalCountForUser(widget.user['user_id']);
    final loadedPosts = await dbHelper.getPostsByUser(widget.user['user_id']);
    if (mounted) {
      setState(() {
        friendNumber = loadedFriendNumber;
        postNumber = loadedPostNumber;
        signalNumber = loadedSignalNumber;
        posts = loadedPosts;
      });
    }

  }

  Future<void> _refreshData() async {
    if (mounted) {
      await _loadData();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.user['username']}"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(File(widget.user['profile'])),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      print('object');
                    },
                    child:Column(
                      children: [
                        Text(
                          "$friendNumber",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Amis',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () {
                      print('object');
                    },
                  child: Column(
                    children: [
                      Text(
                        "$postNumber",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                    ],
                  ),),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () {
                      print('object');
                    },
                    child: Column(
                    children: [
                      Text(
                        '$signalNumber',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Signalé',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),

                    ],
                  ),
                  )
                ],
              ),
              const SizedBox(height: 32),
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(
                          icon: Icon(Icons.image), // Utilisez l'icône d'image pour le premier onglet
                        ),
                        Tab(
                          icon: Icon(Icons.poll), // Utilisez l'icône de sondage pour le deuxième onglet
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 300, // Hauteur de votre contenu de l'onglet
                      child: TabBarView(
                        children: [
                          // Contenu de l'onglet 1 (avec l'icône d'image)
                          ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final Map<String, dynamic> post = posts[index];
                              return Padding(
                                padding: const EdgeInsets.all(0.5),
                                child: Stack(
                                  children: [
                                    // Image avec proportions d'origine
                                    Image.file(
                                      File(post['post']),
                                      fit: BoxFit.contain,
                                    ),
                                    // Coin supérieur droit : PopupMenuButton pour "supprimer"
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: PopupMenuButton(
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Supprimer'),
                                          ),
                                        ],
                                        onSelected: (value) {
                                          if (value == 'delete') {
                                            // Logique pour supprimer l'image
                                          }
                                        },
                                      ),
                                    ),
                                    // Coin inférieur gauche : icône de "like" et nombre de likes
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.favorite, color: Colors.red),
                                          const SizedBox(width: 4),
                                          Text('${post['likes']}'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          //Onglet 2
                          Scaffold()
                        ],
                      ),
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
