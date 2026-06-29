import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'xeza_model.dart';

abstract class XezaEvent {}
class FetchXezaImages extends XezaEvent {}
abstract class XezaState {}
class XezaInitial extends XezaState {}
class XezaLoading extends XezaState {}
class XezaLoaded extends XezaState {
  final List<XezaItem> items;
  XezaLoaded(this.items);
}
class XezaError extends XezaState {
  final String message;
  XezaError(this.message);
}

class XezaBloc extends Bloc<XezaEvent, XezaState> {
  final Dio _dio = Dio();

  XezaBloc() : super(XezaInitial()) {
    on<FetchXezaImages>((event, emit) async {
      emit(XezaLoading());
      try {
        final response = await _dio.get('https://images-api.nasa.gov/search?q=earth&media_type=image');
        
        if (response.statusCode == 200) {
          final List<dynamic> itemsJson = response.data['collection']['items'] ?? [];
          final List<XezaItem> xezaItems = itemsJson.map((json) => XezaItem.fromJson(json)).toList();
          emit(XezaLoaded(xezaItems));
        } else {
          emit(XezaError('เซิร์ฟเวอร์ตอบกลับผิดพลาด: ${response.statusCode}'));
        }
      } catch (e) {
        emit(XezaError('เกิดข้อผิดพลาด: $e'));
      }
    });
  }
}