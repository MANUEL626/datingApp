
import 'package:dating_app/views/ChangeData.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile setting'),
      ),
      body:  SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: const Text('Profile'),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangeProfilePage(),
                  ),
                );
              },
            ),
            const Divider(height: 10, color: Colors.grey),
            ListTile(
              title: const Text('Username'),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UsernamePage(),
                  ),
                );
              },
            ),
            const Divider(height: 10, color: Colors.grey),
            ListTile(
              title: const Text('E-mail'),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  EmailPage(),
                  ),
                );
              },
            ),
            const Divider(height: 10, color: Colors.grey),
            ListTile(
              title: const Text('Password'),
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PasswordPage(),
                  ),
                );
              },
            ),
            const Divider(height: 10, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
