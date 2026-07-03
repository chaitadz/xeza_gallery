import 'package:flutter/material.dart';
import 'injection/injection_container.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
 
void main() {
  runApp(MyApp());
}
 
class MyApp extends StatelessWidget {
  MyApp({super.key, InjectionContainer? container, AppRouter? appRouter})
      : container = container ?? InjectionContainer.create(),
        appRouter = appRouter;

  final InjectionContainer container;
  final AppRouter? appRouter;
  late final AppRouter resolvedRouter =
      appRouter ?? AppRouter(viewModel: container.nasaViewModel);
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nasa BLoC Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, 
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: resolvedRouter.onGenerateRoute,
    );
  }
}