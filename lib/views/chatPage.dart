import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dating_app/var.dart';

import 'home.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({required this.chat});
  final Map<String, dynamic> chat;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  late Timer _timer;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final messageLists = await dbHelper.getMessages(user_id, widget.chat['user_id']);
    setState(() {
      _messages = messageLists.reversed.toList(); // Inverser l'ordre des messages
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.chat['username']}"),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: 'signal',
                child: Text('Signal'),
              ),
              const PopupMenuItem(
                value: 'quit_chat',
                child: Text('Quit chat'),
              ),
              const PopupMenuItem(
                value: 'view_profile',
                child: Text('View profile'),
              ),
            ],
            onSelected: (value) {
              // Effectuer des actions spécifiques en fonction de l'option sélectionnée
              switch (value) {
                case 'signal':
                  _showConfirmationDialog(
                    context,
                    'Signal',
                    'Êtes-vous sûr de vouloir signaler?',
                        () async {
                      await dbHelper.removeFriendship(user_id, widget.chat['user_id']);
                      await dbHelper.reportUser(user_id, widget.chat['user_id']);
                      SnackBar(
                        content: Text('Vous venez de signaler l\'utilisateur "${widget.chat['user_id']}"!'),
                        duration: Duration(seconds: 2),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                  );
                  break;
                case 'quit_chat':
                  _showConfirmationDialog(
                    context,
                    'Quit chat',
                    'Êtes-vous sûr de vouloir quitter le chat?',
                        () async {
                          await dbHelper.removeFriendship(user_id, widget.chat['user_id']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Vous venez de quitter le chat de "${widget.chat['user_id']}"!'),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        }, // Action pour quitter le chat
                  );
                  break;
                case 'view_profile':
                  _showConfirmationDialog(
                    context,
                    'View profile',
                    'Êtes-vous sûr de vouloir voir le profil?',
                    (){}, // Fonction à exécuter si l'utilisateur confirme
                  );
                  break;
                default:
                  break;
              }
            },
            icon: Icon(Icons.more_vert),
          ),
        ],

      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: _messages.map((message) {
                  final bool isFirstMessageOfDay = _messages.indexOf(message) == 0 ||
                      _messages[_messages.indexOf(message) - 1]['date'] != message['date'];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isFirstMessageOfDay) _buildDateDivider(message['date']),
                      _buildMessageBubble(message),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String? messageDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          messageDate ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final bool isCurrentUser = message['sender_id'] == user_id;
    final bool canDelete = isCurrentUser;

    if (message['message'] == null || message['message'].isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () {
              if (canDelete) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Supprimer le message?'),
                    content: Text('Êtes-vous sûr de vouloir supprimer ce message?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await dbHelper.deleteMessage(message['message_id']);
                          Navigator.of(context).pop();
                          _refreshData();
                        },
                        child: Text('Supprimer'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                message['message'] ?? '',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: Colors.grey[200],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Entrez votre message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      await dbHelper.addMessage(user_id, widget.chat['user_id'], message);
      _messageController.clear();
      _refreshData();
    }
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
