import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'nasa_bloc_event.dart';
part 'nasa_bloc_state.dart';

class NasaBlocBloc extends Bloc<NasaBlocEvent, NasaBlocState> {
  NasaBlocBloc() : super(NasaBlocInitial()) {
    on<NasaBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
