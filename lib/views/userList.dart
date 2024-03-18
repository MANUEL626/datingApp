import 'dart:io';

import 'package:flutter/material.dart';
import '../var.dart';
import 'profilePage.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<Map<String, dynamic>> userList = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final users = await dbHelper.getUsersList(user_id);
    setState(() {
      userList = users;
      print(userList);
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      filteredFriends.clear();
    });
  }

  void _filterFriends(String keyword) {
    setState(() {
      filteredFriends = userList
          .where((friend) =>
      friend['username'] != null &&
          friend['username'].toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onChanged: _filterFriends,
        )
            :const Text("Users"),
        actions: [
          IconButton(
            onPressed: _isSearching ? _stopSearch : _startSearch,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
        ]
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: _isSearching ? filteredFriends.length : userList.length,
          itemBuilder: (context, index) {
            final user = _isSearching ? filteredFriends[index] : userList[index];
            return Padding(
              padding: const EdgeInsets.all(0.5),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: FileImage(File(user['profile']??'')),
                ),
                title: Text(user['username']),
                onTap: () async {
                  final existingRequest = await dbHelper.getFriendRequest(user_id, user['user_id']);
                  if (existingRequest != null && existingRequest.isNotEmpty) {
                    final confirmed = await _showConfirmationDialog(context, 'Annuler la demande d\'ami', 'Voulez-vous annuler la demande d\'ami pour ${user['username']} ?');
                    if (confirmed) {
                      await dbHelper.cancelFriendRequest(existingRequest['request_id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Demande d\'ami annulée pour ${user['username']}'),
                        ),
                      );
                    }
                  } else {
                    final friendsExist = await dbHelper.checkIfFriends(user_id, user['user_id']);
                    if (friendsExist) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vous êtes déjà amis avec ${user['username']}'),
                        ),
                      );
                    } else {
                      final confirmed = await _showConfirmationDialog(context, 'Envoyer une demande d\'ami', 'Voulez-vous envoyer une demande d\'ami à ${user['username']} ?');
                      if (confirmed) {
                        await dbHelper.sendFriendRequest(user_id, user['user_id']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Demande d\'ami envoyée à ${user['username']}'),
                          ),
                        );
                      }
                    }
                  }
                },
                trailing: IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(user: user),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Oui'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
