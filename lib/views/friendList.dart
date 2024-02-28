import 'dart:async';
import 'package:flutter/material.dart';
import '../var.dart';
import 'chatPage.dart';

class FriendList extends StatefulWidget {
  const FriendList({Key? key}) : super(key: key);

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  List<Map<String, dynamic>> friendLists = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  Future<void> _loadData() async {
    final friendsLists = await dbHelper.getFriends(user_id);
    setState(() {
      friendLists = friendsLists;
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView.builder(
          itemCount: friendLists.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> friend = friendLists[index];
            return Padding(
              padding: const EdgeInsets.all(0.5),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  // Insérer ici la logique pour afficher l'avatar de l'utilisateur
                ),
                title: Text(friend['username'] ?? ''),
                onTap: () {
                  _navigateToChat(context, friend);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _refreshData();
  }

  void _navigateToChat(BuildContext context, Map<String, dynamic> friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(chat: friend),
      ),
    );
  }
}
