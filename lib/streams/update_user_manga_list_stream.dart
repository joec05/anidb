import 'dart:async';
import 'package:anime_list_app/class/manga_data_class.dart';

class UserMangaListStreamControllerClass{
  final MangaDataClass mangaData;

  UserMangaListStreamControllerClass(this.mangaData);
}

class UpdateUserMangaListStreamClass {
  static final UpdateUserMangaListStreamClass _instance = UpdateUserMangaListStreamClass._internal();
  late StreamController<UserMangaListStreamControllerClass> _updateUserMangaListStreamController;

  factory UpdateUserMangaListStreamClass(){
    return _instance;
  }

  UpdateUserMangaListStreamClass._internal() {
    _updateUserMangaListStreamController = StreamController<UserMangaListStreamControllerClass>.broadcast();
  }

  Stream<UserMangaListStreamControllerClass> get userMangaListStream => _updateUserMangaListStreamController.stream;


  void removeListener(){
    _updateUserMangaListStreamController.stream.drain();
  }

  void emitData(UserMangaListStreamControllerClass data){
    if(!_updateUserMangaListStreamController.isClosed){
      _updateUserMangaListStreamController.add(data);
    }
  }

  void dispose(){
    _updateUserMangaListStreamController.close();
  }
}