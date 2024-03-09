import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, 'my_base2.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user (
            user_id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT,
            mail TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE friend(
            friend_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user1_id INTEGER,
            user2_id INTEGER,
            FOREIGN KEY (user1_id) REFERENCES user (user_id),
            FOREIGN KEY (user2_id) REFERENCES user (user_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE friend_request(
            request_id INTEGER PRIMARY KEY AUTOINCREMENT,
            sender_id INTEGER,
            receiver_id INTEGER,
            status TEXT DEFAULT 'pending',
            FOREIGN KEY (sender_id) REFERENCES user (user_id),
            FOREIGN KEY (receiver_id) REFERENCES user (user_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE message (
            message_id INTEGER PRIMARY KEY AUTOINCREMENT,
            sender_id INTEGER,
            receiver_id INTEGER,
            message TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (sender_id) REFERENCES user (user_id),
            FOREIGN KEY (receiver_id) REFERENCES user (user_id)
          )
        ''');

        await db.execute('''
          CREATE TABLE post (
            post_id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            post TEXT,
            FOREIGN KEY (user_id) REFERENCES user (user_id),
          )
        ''');
      },
    );
  }

  // Ajout d'un utilisateur
  Future<void> insertUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert('user', userData);
  }

  //Ajout d'un post
  Future<void> insertPost(Map<String, dynamic> postData) async {
    final db = await database;
    await db.insert('post', postData);
  }


  // Ajout d'un ami
  Future<void> addFriend(int user1Id, int user2Id) async {
    final db = await database;
    await db.insert(
      'friend',
      {'user1_id': user1Id, 'user2_id': user2Id},
    );
  }

  // Envoie d'une demande d'ami
  Future<void> sendFriendRequest(int senderId, int receiverId) async {
    final db = await database;
    final existingRequest = await getFriendRequest(senderId, receiverId);
    if (existingRequest != null) {
      await cancelFriendRequest(existingRequest['request_id']);
    } else {
      final friendsExist = await checkIfFriends(senderId, receiverId);
      if (!friendsExist) {
        await db.insert(
          'friend_request',
          {'sender_id': senderId, 'receiver_id': receiverId},
        );
      } else {
        print('Vous êtes déjà amis');
      }
    }
  }

  // Récupère une demande d'ami
  Future<Map<String, dynamic>?> getFriendRequest(int senderId, int receiverId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'friend_request',
      where: 'sender_id = ? AND receiver_id = ?',
      whereArgs: [senderId, receiverId],
    );
    if (result.isEmpty) {
      return null;
    }
    return result.first;
  }

  // Annulation d'une demande d'ami
  Future<void> cancelFriendRequest(int requestId) async {
    final db = await database;
    await db.delete(
      'friend_request',
      where: 'request_id = ?',
      whereArgs: [requestId],
    );
  }

  // Vérifie si deux utilisateurs sont amis
  Future<bool> checkIfFriends(int user1Id, int user2Id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT COUNT(*) AS count
    FROM friend
    WHERE (user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?)
    ''', [user1Id, user2Id, user2Id, user1Id]);
    final int count = Sqflite.firstIntValue(results)!;
    return count > 0;
  }

  // Récupérer la liste des demandes d'ami envoyées par l'utilisateur avec les noms d'utilisateur des destinataires
  Future<List<Map<String, dynamic>>> getSentFriendRequests(int userId) async {
    final db = await database;
    return db.rawQuery('''
    SELECT friend_request.*, user.username AS receiver_username
    FROM friend_request
    INNER JOIN user ON friend_request.receiver_id = user.user_id
    WHERE friend_request.sender_id = ?
  ''', [userId]);
  }

  // Récupérer la liste des demandes d'ami reçues par l'utilisateur avec les noms d'utilisateur des expéditeurs
  Future<List<Map<String, dynamic>>> getReceivedFriendRequests(int userId) async {
    final db = await database;
    return db.rawQuery('''
    SELECT friend_request.*, user.username AS sender_username
    FROM friend_request
    INNER JOIN user ON friend_request.sender_id = user.user_id
    WHERE friend_request.receiver_id = ?
  ''', [userId]);
  }

  // Vérification d'utilisateur
  Future<List<Map<String, dynamic>>> getUser(String username) async {
    final db = await database;
    return db.query('user', where: 'username =?', whereArgs: [username]);
  }

  // Vérification par e-mail
  Future<List<Map<String, dynamic>>> getUserMail(String mail) async {
    final db = await database;
    return db.query('user', where: 'mail =?', whereArgs: [mail]);
  }

  // Affichage de tous les utilisateurs
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return db.query('user');
  }


  // Récupération de la liste des utilisateurs (sauf l'utilisateur avec l'ID spécifié)
  Future<List<Map<String, dynamic>>> getUsersList(int id) async {
    final db = await database;
    return db.query('user', where: 'user_id != ?', whereArgs: [id]);
  }

  // Ajout d'un message
  Future<void> addMessage(int senderId, int receiverId, String message) async {
    final db = await database;
    await db.insert(
      'message',
      {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message,
        'timestamp': DateTime.now().toUtc().toIso8601String(), // Ajout du timestamp au format ISO 8601
      },
    );
  }

  // Récupérer les messages entre deux utilisateurs, regroupés par date
  Future<List<Map<String, dynamic>>> getMessages(int userId1, int userId2) async {
    final db = await database;
    final List<Map<String, dynamic>> rawMessages = await db.rawQuery('''
      SELECT *, 
        DATE(timestamp, 'localtime') AS date  -- Extrait la date des timestamp
      FROM message
      WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)
      ORDER BY timestamp DESC  -- Du plus récent au plus ancien
    ''', [userId1, userId2, userId2, userId1]);

    // Grouper les messages par date
    final Map<String, List<Map<String, dynamic>>> groupedMessages = {};
    for (final message in rawMessages) {
      final String date = message['date'] as String;
      if (!groupedMessages.containsKey(date)) {
        groupedMessages[date] = [];
      }
      groupedMessages[date]!.add(message);
    }

    // Convertir le Map en List
    final List<Map<String, dynamic>> messages = [];
    groupedMessages.forEach((key, value) {
      messages.add({'date': key});
      messages.addAll(value); // Ajout des messages du plus récent au plus ancien
    });

    return messages;
  }

  // Supprimer un message
  Future<void> deleteMessage(int messageId) async {
    final db = await database;
    await db.delete(
      'message',
      where: 'message_id = ?',
      whereArgs: [messageId],
    );
  }

  // Récupérer la liste des utilisateurs amis avec l'utilisateur donné
  Future<List<Map<String, dynamic>>> getFriends(int userId) async {
    final db = await database;
    return db.rawQuery('''
    SELECT user.*
    FROM user
    INNER JOIN friend ON (user.user_id = friend.user1_id OR user.user_id = friend.user2_id)
    WHERE (friend.user1_id = ? OR friend.user2_id = ?) AND user.user_id != ?
  ''', [userId, userId, userId]); // Exclure l'utilisateur lui-même
  }

  Future<List<Map<String, dynamic>>> getUsersWithMessages(int userId) async {
    final db = await database;
    return db.rawQuery('''
    SELECT user.*, MAX(message.timestamp) AS last_message_timestamp
    FROM user
    INNER JOIN message ON user.user_id = message.sender_id OR user.user_id = message.receiver_id
    WHERE (message.sender_id = ? OR message.receiver_id = ?)
      AND user.user_id != ?
    GROUP BY user.user_id
    ORDER BY last_message_timestamp DESC
  ''', [userId, userId, userId]);
  }


  //uttilisateur connecté
  Future<Map<String, dynamic>?> getLoggedInUser(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> users = await db.query('user', where: 'user_id = ?', whereArgs: [userId], limit: 1);
    return users.isNotEmpty ? users.first : null;
  }

}
