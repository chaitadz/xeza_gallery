// lib/injection_container.dart
import 'package:dio/dio.dart';
import 'package:xeza_gallery/features/nasa_gallery/data/datasources/nasa_remote_data_source_impl.dart';
import 'package:xeza_gallery/features/nasa_gallery/domain/repositories/nasa_repository_impl.dart';
import 'package:xeza_gallery/features/nasa_gallery/presentation/bloc/nasa_bloc_bloc.dart';

// ✅ Dependency Injection - สร้างและเชื่อมต่อ dependencies
class InjectionContainer {
  static NasaBlocBloc createNasaBlocBloc() {
    // 1️⃣ สร้าง Dio
    final dio = Dio();

    // 2️⃣ สร้าง DataSource แล้วส่ง Dio
    final remoteDataSource = NasaRemoteDataSourceImpl(dio);

    // 3️⃣ สร้าง Repository แล้วส่ง DataSource
    final repository = NasaRepositoryImpl(remoteDataSource);

    // 4️⃣ สร้าง BLoC แล้วส่ง Repository
    return NasaBlocBloc(repository);
  }
}