import 'package:flutter/material.dart';

import 'home.dart';


class MyStepper extends StatefulWidget {
  @override
  _MyStepperState createState() => _MyStepperState();
}

class _MyStepperState extends State<MyStepper> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horizontal Stepper'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                // Page 1
                Container(
                  color: Colors.blue,
                  child: const Center(
                    child: Text('Page 1 Content', style: TextStyle(color: Colors.white)),
                  ),
                ),
                // Page 2
                Container(
                  color: Colors.green,
                  child: const Center(
                    child: Text('Page 2 Content', style: TextStyle(color: Colors.white)),
                  ),
                ),
                // Page 3
                Container(
                  color: Colors.orange,
                  child: const Center(
                    child: Text('Page 3 Content', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    width: 15.0,
                    height: 3.0,
                    color: _currentPage == i ? Colors.blue : Colors.grey,
                  ),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _currentPage > 0
                    ? () {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                }
                    : null,
                child: Text('Précédent'),
              ),
              ElevatedButton(
                onPressed: _currentPage < 2
                    ? () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                }
                    : () {
                  // L'utilisateur est sur la dernière page, rediriger vers HomePage()
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: Text(_currentPage < 2 ? 'Suivant' : 'Terminer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
