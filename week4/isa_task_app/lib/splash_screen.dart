import 'package:flutter/material.dart';
import 'package:isa_task_app/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _navigateToNextScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 22, 22, 22),
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
                _buildPage(
                  image:
                      'assets/images/splash_1.png', // Replace with your first illustration
                  text: "Organize your tasks efficiently",
                ),
                _buildPage(
                  image:
                      'assets/images/splash_2.png', // Replace with your second illustration
                  text: "Track your progress seamlessly",
                ),
                _buildPage(
                  image:
                      'assets/images/splash_3.png', // Replace with your third illustration
                  text: "Get notified about important updates",
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              // Updated to 3 pages
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                width: _currentPage == index ? 12.0 : 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.purple : Colors.grey,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              );
            }),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () => _navigateToNextScreen(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: CircleBorder(),
                padding: EdgeInsets.all(20.0),
              ),
              child: Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required String image, required String text}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 50.0),
        Image.asset(
          'assets/images/isa-vesit-white-logo.png',
          height: 200,
        ),
        SizedBox(height: 40.0),
        Image.asset(image, height: 250.0), // Add images in your assets folder
        SizedBox(height: 20.0),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
