part of 'nasa_bloc_bloc.dart';

@immutable
sealed class NasaBlocState {}

final class NasaBlocInitial extends NasaBlocState {}

final class NasaBlocLoading extends NasaBlocState {}

final class NasaBlocLoaded extends NasaBlocState {
  // ✅ เปลี่ยนจาก List<NasaItemModel> เป็น List<NasaItem>
  // ❌ ทำไม? เพราะ Repository.fetchImages() return List<NasaItem> (Entity)
  // Model ใช้เฉพาะใน Data layer (JSON parsing) เท่านั้น
  final List<NasaItem> items;
  
  NasaBlocLoaded(this.items);
}

final class NasaBlocError extends NasaBlocState {
  final String message;
  NasaBlocError(this.message);
}