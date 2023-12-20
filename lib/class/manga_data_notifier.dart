import 'package:anime_list_app/class/manga_data_class.dart';
import 'package:flutter/material.dart';

class MangaDataNotifier {
  int id;
  ValueNotifier<MangaDataClass> notifier;
  
  MangaDataNotifier(
    this.id,
    this.notifier
  );
}