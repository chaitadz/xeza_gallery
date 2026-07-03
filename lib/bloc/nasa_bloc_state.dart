part of 'nasa_bloc_bloc.dart';

@immutable
sealed class NasaBlocState {}

final class NasaBlocInitial extends NasaBlocState {}

final class NasaBlocLoading extends NasaBlocState {}

final class NasaBlocLoaded extends NasaBlocState {
  final List<NasaItem> items;
  NasaBlocLoaded(this.items);
}

final class NasaBlocError extends NasaBlocState {
  final String message;
  NasaBlocError(this.message);
}
