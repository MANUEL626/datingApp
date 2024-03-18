import 'dart:async';
import 'dart:io';
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
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> filteredFriends = [];

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
      filteredFriends = friendLists
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
            :const Text("Friends"),
        actions: [
          IconButton(
            onPressed: _isSearching ? _stopSearch : _startSearch,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView.builder(
          itemCount: _isSearching ? filteredFriends.length : friendLists.length,
          itemBuilder: (context, index) {
            final Map<String, dynamic> friend = _isSearching ? filteredFriends[index] : friendLists[index];
            return Padding(
              padding: const EdgeInsets.all(0.5),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: FileImage(File(friend['profile']?? '')),
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
