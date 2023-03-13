import 'package:flutter/material.dart';
import 'package:tiny_rebort_poc/square_map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: SquareMapScreen() //test(),
        );
  }
}

//
// {lat: 37.08263434700484, lng: -121.97304390370844},
// {lat: 37.09055725997582, lng: -121.818721331656},
// {lat: 37.14366481679104, lng: -121.82350169867276},
// {lat: 37.13599763684532, lng: -121.96832388639449}
