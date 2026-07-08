import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../nasa_repository/domain/entities/nasa_item.dart';
import '../../../nasa_repository/domain/repositories/nasa_repository.dart';

part 'nasa_bloc_event.dart';
part 'nasa_bloc_state.dart';

class NasaBlocBloc extends Bloc<NasaBlocEvent, NasaBlocState> {
  final NasaRepository _repository;

  NasaBlocBloc(this._repository) : super(NasaBlocInitial()) {
    on<FetchNasaImages>((event, emit) async {
      emit(NasaBlocLoading());
      await Future.delayed(const Duration(seconds: 2));

      try {
        final nasaItems = await _repository.fetchImages();
        emit(NasaBlocLoaded(nasaItems));
      } catch (e) {
        emit(NasaBlocError('เกิดข้อผิดพลาด: $e'));
      }
    });
  }
}