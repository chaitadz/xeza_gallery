// lib/features/nasa_gallery/presentation/bloc/nasa_bloc_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
// ✅ ลบ: import '../../data/models/nasa_item_model.dart';
// ✅ เพิ่ม: import Entity แทน Model
import '../../domain/entities/nasa_item.dart';
import '../../domain/repositories/nasa_repository.dart';

part 'nasa_bloc_event.dart';
part 'nasa_bloc_state.dart';

class NasaBlocBloc extends Bloc<NasaBlocEvent, NasaBlocState> {
  final NasaRepository repository; // ✅ Inject repository

  NasaBlocBloc(this.repository) : super(NasaBlocInitial()) {
    on<FetchNasaImages>((event, emit) async {
      emit(NasaBlocLoading());

      try {
        final nasaItems = await repository.fetchImages();
        // ✅ nasaItems เป็น List<NasaItem> ตรงกับ State ที่ต้องการ
        emit(NasaBlocLoaded(nasaItems));
      } catch (e) {
        emit(NasaBlocError('เกิดข้อผิดพลาด: $e'));
      }
    });
  }
}