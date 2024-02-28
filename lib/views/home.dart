import 'package:dating_app/views/login.dart';
import 'package:dating_app/views/postPage.dart';
import 'package:dating_app/views/userList.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../var.dart';
import 'chatPage.dart';
import 'friendList.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(title: 'Home'),
    RequestsPageContent(title: 'Request'),
    const AccountPageContent(title: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1_rounded),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  List<Map<String, dynamic>> friendLists = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final friendsLists = await dbHelper.getUsersWithMessages(user_id);
    setState(() {
      friendLists = friendsLists ?? []; // Assurez-vous que friendsLists n'est pas null
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendList()),
                );
              },
              icon: const Icon(Icons.message),
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Chats"),
              Tab(text: "Post"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Onglet 1
            RefreshIndicator(
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

            // Onglet 2
            const Center(
              child: Text("Contenu de l'onglet Post"),
            ),
          ],
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


class RequestsPageContent extends StatefulWidget {
  final String title;

  RequestsPageContent({Key? key, required this.title}) : super(key: key);

  @override
  _RequestsPageContentState createState() => _RequestsPageContentState();
}

class _RequestsPageContentState extends State<RequestsPageContent> {
  List<Map<String, dynamic>> receivedList = [];
  List<Map<String, dynamic>> sendList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final sendLists = await dbHelper.getSentFriendRequests(user_id);
    final receivedLists = await dbHelper.getReceivedFriendRequests(user_id);
    setState(() {
      sendList = sendLists;
      receivedList = receivedLists;
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("DatingApp"),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserList()),
                );
              },
              icon: Icon(Icons.person_add),
            )
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: "Receiveds"),
              Tab(text: "Sents"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
// Onglet 1
            Center(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView.builder(
                  itemCount: receivedList.length,
                  itemBuilder: (context, index) {
                    final item = receivedList[index];
                    return Padding(
                      padding: const EdgeInsets.all(0.5),
                      child: ListTile(
                        leading: CircleAvatar(),
                        title: Text(item['sender_username'] ?? ''),
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmer'),
                                content: Text('Voulez-vous accepter ou refuser la demande ?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text('Refuser'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text('Accepter'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmed != null && confirmed) {
                            // Ajouter l'ami à la base de données
                            await dbHelper.addFriend(item['receiver_id'], item['sender_id']);
                            // Supprimer la demande après l'action
                            await dbHelper.cancelFriendRequest(item['request_id']);
                            setState(() {
                              receivedList = List.from(receivedList);
                              receivedList.removeAt(index);
                            });
                          }
                        },

                      ),
                    );
                  },
                ),
              ),
            ),

// Onglet 2
            Center(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: ListView.builder(
                  itemCount: sendList.length,
                  itemBuilder: (context, index) {
                    final item = sendList[index];
                    return Padding(
                      padding: const EdgeInsets.all(0.5),
                      child: ListTile(
                        leading: CircleAvatar(),
                        title: Text(item['receiver_username'] ?? ''),
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmer'),
                                content: Text('Voulez-vous annuler la demande ?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text('Confirmer'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmed != null && confirmed) {
                            // Supprimer la demande après l'action
                            await dbHelper.cancelFriendRequest(item['request_id']);
                            setState(() {
                              sendList = List.from(sendList);
                              sendList.removeAt(index);
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}


class AccountPageContent extends StatelessWidget {
  final String title;

  const AccountPageContent({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${userInfo['username']}"),
        actions: [
          IconButton(onPressed: (){
            /*Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostPage(),
              ),
            );*/
          },
              icon: Icon(Icons.add_box)),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          title: Text('Profile'),
                          onTap: () {
                            // Action à effectuer lorsque l'élément est cliqué
                            Navigator.pop(context); // Ferme le BottomSheet
                          },
                        ),
                        ListTile(
                          title: Text('Paramètres'),
                          onTap: () {
                            // Action à effectuer lorsque l'élément est cliqué
                            Navigator.pop(context); // Ferme le BottomSheet
                          },
                        ),
                        ListTile(
                          title: Text('Politique de confidentialité'),
                          onTap: () {
                            // Action à effectuer lorsque l'élément est cliqué
                            Navigator.pop(context); // Ferme le BottomSheet
                          },
                        ),
                        ListTile(
                          title: Text('Se déconnecter'),
                          onTap: () {
                            _showLogoutAlertDialog(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                //backgroundImage: AssetImage('assets/avatar.png'), // Remplacez 'assets/avatar.png' par le chemin de votre image
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        '109',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Amis',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 32),
                  Column(
                    children: [
                      Text(
                        '38',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 32),
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(
                          icon: Icon(Icons.image), // Utilisez l'icône d'image pour le premier onglet
                        ),
                        Tab(
                          icon: Icon(Icons.poll), // Utilisez l'icône de sondage pour le deuxième onglet
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 200, // Hauteur de votre contenu de l'onglet
                      child: TabBarView(
                        children: [
                          // Contenu de l'onglet 1 (avec l'icône d'image)
                          Placeholder(), // Remplacez Placeholder() par votre contenu
                          // Contenu de l'onglet 2 (avec l'icône de sondage)
                          Placeholder(), // Remplacez Placeholder() par votre contenu
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),


    );
  }
  void _showLogoutAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Déconnexion'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the AlertDialog
              },
              child: Text('Annuler'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            TextButton(
              onPressed: () {
                /*setState()
                {
                  connect = false;
                }*/
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
              child: Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        );
      },
    );
  }
}
