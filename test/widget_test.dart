// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:xeza_gallery/features/nasa_gallery/model/nasa_item.dart';
import 'package:xeza_gallery/features/nasa_gallery/repository/nasa_repository.dart';
import 'package:xeza_gallery/features/nasa_gallery/viewmodel/nasa_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xeza_gallery/main.dart';
import 'package:xeza_gallery/routes/app_router.dart';

class FakeNasaRepository implements NasaRepository {
  @override
  Future<List<NasaItem>> fetchEarthImages() async {
    return <NasaItem>[];
  }
}

void main() {
  testWidgets('renders the gallery shell', (WidgetTester tester) async {
    final viewModel = NasaViewModel(FakeNasaRepository());

    await tester.pumpWidget(
      MyApp(
        appRouter: AppRouter(viewModel: viewModel),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nasa Earth Gallery'), findsOneWidget);
  });
}
