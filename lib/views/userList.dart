import 'package:flutter/material.dart';
import '../var.dart';

class UserList extends StatefulWidget {
  const UserList({Key? key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<Map<String, dynamic>> userList = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: userList.length,
          itemBuilder: (context, index) {
            final user = userList[index];
            return Padding(
              padding: const EdgeInsets.all(0.5),
              child: ListTile(
                leading: CircleAvatar(),
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
