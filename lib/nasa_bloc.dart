import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'nasa_model.dart';

abstract class NasaEvent {}
class FetchNasaImages extends NasaEvent {}
abstract class NasaState {}
class NasaInitial extends NasaState {}
class NasaLoading extends NasaState {}
class NasaLoaded extends NasaState {
  final List<NasaItem> items;
  NasaLoaded(this.items);
}
class NasaError extends NasaState {
  final String message;
  NasaError(this.message);
}

class NasaBloc extends Bloc<NasaEvent, NasaState> {
  final Dio _dio = Dio();

  NasaBloc() : super(NasaInitial()) {
    on<FetchNasaImages>((event, emit) async {
      emit(NasaLoading());
      try {
        final response = await _dio.get('https://images-api.nasa.gov/search?q=earth&media_type=image');
        
        if (response.statusCode == 200) {
          final List<dynamic> itemsJson = response.data['collection']['items'] ?? [];
          final List<NasaItem> NasaItems = itemsJson.map((json) => NasaItem.fromJson(json)).toList();
          emit(NasaLoaded(NasaItems));
        } else {
          emit(NasaError('เซิร์ฟเวอร์ตอบกลับผิดพลาด: ${response.statusCode}'));
        }
      } catch (e) {
        emit(NasaError('เกิดข้อผิดพลาด: $e'));
      }
    });
  }
}