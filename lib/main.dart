import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:ingeniusly/splash_screen.dart'; // Import the SplashScreen
import 'package:ingeniusly/LoginPage.dart';
import 'package:ingeniusly/RegisterPage.dart';
import 'package:ingeniusly/home.dart';
import '/pages/Search.dart';
import 'calendar.dart';
import 'custom_app_bar.dart';

Future<void> main() async {
  // Ensure that the widgets binding is initialized before we call the init function
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.white,
      ),
      home: SplashScreen(), // Start with SplashScreen
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.white,
      ),
      // Use StreamBuilder to listen to authentication state changes
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return MainPage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  final pages = [TreeViewPage(), Home(), CalendarPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        imagePath: 'images/inGeniusly.png',
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        unselectedItemColor: Color.fromARGB(255, 2, 10, 99),
        selectedItemColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 255, 210, 77),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map_sharp,
            ),
            label: 'Decide Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.adf_scanner_rounded),
            label: 'Investigate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
