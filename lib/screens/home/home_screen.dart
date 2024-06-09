import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false; // This will disable the back button
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home Screen'),
          automaticallyImplyLeading: false, // This will remove the back button
        ),
        body: Center(
          child: Text('Welcome to Hello NITR'),
        ),
      ),
    );
  }
}
