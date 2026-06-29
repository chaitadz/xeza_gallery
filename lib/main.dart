import 'package:xeza_gallery/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'xeza_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xeza BLoC Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, 
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => XezaBloc()..add(FetchXezaImages()),
        child: const MyHomePage(title: 'Xeza Earth Gallery'),
      ),
    );
  }
}