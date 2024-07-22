import 'dart:async';
import 'package:anidb/global_files.dart';

class UserMangaListStreamControllerClass{
  final MangaDataClass mangaData;
  final String? oldStatus;
  final String? newStatus;

  UserMangaListStreamControllerClass(this.mangaData, this.oldStatus, this.newStatus);
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