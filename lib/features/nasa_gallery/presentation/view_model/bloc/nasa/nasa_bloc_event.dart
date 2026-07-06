part of 'nasa_bloc_bloc.dart';

@immutable
sealed class NasaBlocEvent {}

final class FetchNasaImages extends NasaBlocEvent {}
