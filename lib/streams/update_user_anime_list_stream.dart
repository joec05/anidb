import 'dart:async';
import 'package:anidb/global_files.dart';

class UserAnimeListStreamControllerClass{
  final AnimeDataClass animeData;
  final String? oldStatus;
  final String? newStatus;

  UserAnimeListStreamControllerClass(this.animeData, this.oldStatus, this.newStatus);
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