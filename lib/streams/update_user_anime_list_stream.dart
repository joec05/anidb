import 'dart:async';
import 'package:anime_list_app/class/anime_data_class.dart';

class UserAnimeListStreamControllerClass{
  final AnimeDataClass animeData;

  UserAnimeListStreamControllerClass(this.animeData);
}

class UpdateUserAnimeListStreamClass {
  static final UpdateUserAnimeListStreamClass _instance = UpdateUserAnimeListStreamClass._internal();
  late StreamController<UserAnimeListStreamControllerClass> _updateUserAnimeListStreamController;

  factory UpdateUserAnimeListStreamClass(){
    return _instance;
  }

  UpdateUserAnimeListStreamClass._internal() {
    _updateUserAnimeListStreamController = StreamController<UserAnimeListStreamControllerClass>.broadcast();
  }

  Stream<UserAnimeListStreamControllerClass> get userAnimeListStream => _updateUserAnimeListStreamController.stream;


  void removeListener(){
    _updateUserAnimeListStreamController.stream.drain();
  }

  void emitData(UserAnimeListStreamControllerClass data){
    if(!_updateUserAnimeListStreamController.isClosed){
      _updateUserAnimeListStreamController.add(data);
    }
  }

  void dispose(){
    _updateUserAnimeListStreamController.close();
  }
}