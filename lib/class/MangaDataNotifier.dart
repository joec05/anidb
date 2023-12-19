import 'package:anime_list_app/class/MangaDataClass.dart';
import 'package:flutter/material.dart';

class MangaDataNotifier {
  int id;
  ValueNotifier<MangaDataClass> notifier;
  
  MangaDataNotifier(
    this.id,
    this.notifier
  );
}