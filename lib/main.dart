import 'package:xeza_gallery/features/nasa_gallery/presentation/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xeza_gallery/injection_container.dart';
import 'package:xeza_gallery/core/theme/app_theme.dart';
 
void main() {
  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nasa BLoC Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getDarkTheme(),
      home: BlocProvider(
        create: (context) => InjectionContainer.createNasaBlocBloc(),
        child: const MyHomePage(title: 'Nasa Earth Gallery'),
      ),
    );
  }
}