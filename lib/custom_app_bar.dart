import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ingeniusly/ProfilePage.dart';
import 'package:ingeniusly/SettingsPage.dart'; // Import your settings page

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String imagePath;

  CustomAppBar({required this.imagePath});

  Future<String> _getProfileImageUrl() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(
              'users') // Adjust this collection name to match your Firestore structure
          .doc(user.uid)
          .get();

      return userDoc['profileImageUrl'] ??
          'https://firebasestorage.googleapis.com/v0/b/my-first-firebase-app-8dc6f.appspot.com/o/default.jpeg?alt=media&token=b211bd1e-08b8-4e6e-91cd-1791538e0933';
    }
    return 'https://firebasestorage.googleapis.com/v0/b/my-first-firebase-app-8dc6f.appspot.com/o/default.jpeg?alt=media&token=b211bd1e-08b8-4e6e-91cd-1791538e0933';
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  imagePath: '',
                ),
              ),
            );
          },
          child: FutureBuilder<String>(
            future: _getProfileImageUrl(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(
                  radius: 16.0,
                  backgroundColor: Colors.amber,
                  child:
                      CircularProgressIndicator(), // Display a loading indicator
                );
              }

              if (snapshot.hasError) {
                return CircleAvatar(
                  radius: 16.0,
                  backgroundColor: Colors.amber,
                  child: Icon(
                    Icons.person,
                    size: 30.0,
                    color: Colors.white,
                  ),
                );
              }

              return CircleAvatar(
                radius: 16.0,
                backgroundColor: Colors.amber,
                backgroundImage: NetworkImage(
                  snapshot.data ??
                      'https://firebasestorage.googleapis.com/v0/b/my-first-firebase-app-8dc6f.appspot.com/o/default.jpeg?alt=media&token=b211bd1e-08b8-4e6e-91cd-1791538e0933',
                ),
                child: snapshot.data == null
                    ? Icon(
                        Icons.person,
                        size: 30.0,
                        color: Colors.white,
                      )
                    : null,
              );
            },
          ),
        ),
      ),
      title: Transform.translate(
        offset: Offset(-5, 3.5),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          height: 65.0,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
            child: Icon(
              Icons.settings,
              size: 28.0,
              color: Color.fromARGB(255, 10, 101, 192),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
