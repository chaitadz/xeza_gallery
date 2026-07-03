import 'package:flutter/material.dart';

import '../features/nasa_gallery/model/nasa_item.dart';
import '../features/nasa_gallery/view/pages/detail_page.dart';
import '../features/nasa_gallery/view/pages/home_page.dart';
import '../features/nasa_gallery/viewmodel/nasa_viewmodel.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter({required this.viewModel});

  final NasaViewModel viewModel;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<dynamic>(
          builder: (context) => HomePage(
            title: 'Nasa Earth Gallery',
            viewModel: viewModel,
          ),
        );
      case AppRoutes.detail:
        final item = settings.arguments as NasaItem;
        return MaterialPageRoute<dynamic>(
          builder: (context) => DetailPage(item: item),
        );
      default:
        return MaterialPageRoute<dynamic>(
          builder: (context) => HomePage(
            title: 'Nasa Earth Gallery',
            viewModel: viewModel,
          ),
        );
    }
  }
}