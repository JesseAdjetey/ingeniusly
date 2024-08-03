import 'package:flutter/material.dart';
import 'package:ingeniusly/LoginPage.dart';
import 'package:slide_action/slide_action.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isBiometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricsSetting();
  }

  void _loadBiometricsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isBiometricsEnabled = prefs.getBool('biometricsEnabled') ?? false;
    });
  }

  void _updateBiometricsSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isBiometricsEnabled = value;
      prefs.setBool('biometricsEnabled', value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(height: 50.0),
                  Image.asset(
                    'images/inGeniusly.png',
                    height: 100.0,
                  ),
                  SizedBox(height: 8.0),
                ],
              ),
            ),
            SizedBox(height: 32.0),
            ListTile(
              leading: Icon(Icons.fingerprint),
              title: Text('Enable Biometrics'),
              trailing: Switch(
                activeColor: Colors.amber,
                activeTrackColor: Color.fromARGB(255, 255, 219, 111),
                value: isBiometricsEnabled,
                onChanged: (value) {
                  _updateBiometricsSetting(value);
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Manage Notifications'),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // Handle notifications management here
              },
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Terms and Conditions'),
              trailing: Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // Handle privacy settings here
              },
            ),
            SizedBox(height: 60.0),
            Center(
              child: SlideAction(
                action: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'images/inGeniusly.png',
                                height: 80.0,
                              ),
                              Text(
                                'Are you sure you want to leave? 😢\nWe’ll miss you!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text('Logout'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 255, 210, 77),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                trackBuilder: (context, state) {
                  double progress = state.thumbFractionalPosition;

                  return Container(
                    height: 60.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 210, 77),
                          Color.fromARGB(255, 255, 210, 77)
                              .withOpacity(1 - progress),
                          Colors.white.withOpacity(progress),
                        ],
                        stops: [0.0, 1.0 - progress, 1.0],
                        begin: Alignment.topRight,
                        end: Alignment.topLeft,
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Slide to Logout 👋',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                thumbBuilder: (context, state) {
                  return Container(
                    height: 60.0,
                    width: 60.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward,
                        color: Color.fromARGB(255, 255, 210, 77),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
