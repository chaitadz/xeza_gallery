import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import '../model/nasa_model.dart';

part 'nasa_bloc_event.dart';
part 'nasa_bloc_state.dart';
class NasaBlocBloc extends Bloc<NasaBlocEvent, NasaBlocState> {
  final Dio _dio = Dio();

  NasaBlocBloc() : super(NasaBlocInitial()) {
    on<FetchNasaImages>((event, emit) async {
      emit(NasaBlocLoading());

      try {
        final response = await _dio.get(
          'https://images-api.nasa.gov/search?q=earth&media_type=image',
        );

        if (response.statusCode == 200) {
          final List<dynamic> items =
              response.data['collection']['items'] ?? [];

          final List<NasaItem> nasaItems = items.map((item) {
            final data = (item['data'] as List).first;
            final links = item['links'] as List?;

            String imageUrl = 'https://play-lh.googleusercontent.com/ei29iYY5zisiQuJ-GfX3Qpe2BzsLYgJi5-yllcJt4ciYHdgdtWv62kf_v5zLW4wNHw=w7680-h4320-rw';

            if (links != null && links.isNotEmpty) {
              imageUrl = links.first['href'] ?? imageUrl;

              // if (imageUrl.startsWith('http://')) {
              //   imageUrl = imageUrl.replaceFirst(
              //     'http://',
              //     'https://',
              //   );
              // }
            }

            return NasaItem.fromJson({
              'title': data['title'],
              'center': data['center'],
              'dateCreated': data['date_created'],
              'description': data['description'],
              'imageUrl': imageUrl,
              'keywords': data['keywords'] ?? [],
            });
          }).toList();

          emit(NasaBlocLoaded(nasaItems));
        } else {
          emit(
            NasaBlocError(
              'เซิร์ฟเวอร์ตอบกลับผิดพลาด: ${response.statusCode}',
            ),
          );
        }
      } catch (e) {
        emit(
          NasaBlocError('เกิดข้อผิดพลาด: $e'),
        );
      }
    });
  }
}