import 'package:firebase_core/firebase_core.dart';
import 'package:firebaseapp/firestore_islemleri.dart';
import 'package:firebaseapp/login_islemleri.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: App(),
    );
  }
}

class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("firebaseapp"),),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginIslemleri()));
                  },child: Text("Login İşlemleri"),color: Colors.deepPurple,),
                  RaisedButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FirestoreIslemleri()));
                  },child: Text("FireStore İşlemleri"),color: Colors.teal,),
                ],
              ),
          );

        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

