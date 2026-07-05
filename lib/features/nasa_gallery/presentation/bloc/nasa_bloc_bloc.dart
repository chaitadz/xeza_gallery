import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../domain/entities/nasa_item.dart';
import '../../domain/repositories/nasa_repository.dart';

part 'nasa_bloc_event.dart';
part 'nasa_bloc_state.dart';

class NasaBlocBloc extends Bloc<NasaBlocEvent, NasaBlocState> {
  final NasaRepository repository;

  NasaBlocBloc(this.repository) : super(NasaBlocInitial()) {
    on<FetchNasaImages>((event, emit) async {
      emit(NasaBlocLoading());

      try {
        final nasaItems = await repository.fetchImages();
        emit(NasaBlocLoaded(nasaItems));
      } catch (e) {
        emit(NasaBlocError('เกิดข้อผิดพลาด: $e'));
      }
    });
  }
}