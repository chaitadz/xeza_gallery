import 'package:get_storage/get_storage.dart';
import 'package:xeza_gallery/presentation/view/pages/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xeza_gallery/injection_container.dart';
import 'package:xeza_gallery/core/theme/app_theme.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => InjectionContainer.createNasaBlocBloc()),
        BlocProvider(create: (_) => InjectionContainer.createFavoritesBlocBloc()),
      ],
      child: MaterialApp(
        title: 'Nasa BLoC Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getDarkTheme(),
        home: const LandingScreen(),
      ),
    );
  }
}