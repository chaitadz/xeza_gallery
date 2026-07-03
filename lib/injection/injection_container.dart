import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../features/nasa_gallery/repository/nasa_repository.dart';
import '../features/nasa_gallery/viewmodel/nasa_viewmodel.dart';

class InjectionContainer {
  InjectionContainer._({
    required this.dio,
    required this.nasaRepository,
    required this.nasaViewModel,
  });

  factory InjectionContainer.create() {
    final Dio dio = DioClient.create();
    final NasaRepository nasaRepository = NasaRepositoryImpl(dio);
    final NasaViewModel nasaViewModel = NasaViewModel(nasaRepository);

    return InjectionContainer._(
      dio: dio,
      nasaRepository: nasaRepository,
      nasaViewModel: nasaViewModel,
    );
  }

  final Dio dio;
  final NasaRepository nasaRepository;
  final NasaViewModel nasaViewModel;
}