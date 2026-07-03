import 'package:flutter/foundation.dart';

import '../model/nasa_item.dart';
import '../repository/nasa_repository.dart';

enum NasaViewStatus {
  initial,
  loading,
  loaded,
  error,
}

class NasaViewModel extends ChangeNotifier {
  NasaViewModel(this._repository);

  final NasaRepository _repository;

  NasaViewStatus _status = NasaViewStatus.initial;
  List<NasaItem> _items = <NasaItem>[];
  String _errorMessage = '';

  NasaViewStatus get status => _status;
  List<NasaItem> get items => List.unmodifiable(_items);
  String get errorMessage => _errorMessage;

  Future<void> loadEarthImages() async {
    if (_status == NasaViewStatus.loading) {
      return;
    }

    _status = NasaViewStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _items = await _repository.fetchEarthImages();
      _status = NasaViewStatus.loaded;
    } catch (error) {
      _errorMessage = 'เกิดข้อผิดพลาด: $error';
      _status = NasaViewStatus.error;
    }

    notifyListeners();
  }
}