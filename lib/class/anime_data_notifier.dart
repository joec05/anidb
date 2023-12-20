import 'package:anime_list_app/class/anime_data_class.dart';
import 'package:flutter/material.dart';

class AnimeDataNotifier {
  int id;
  ValueNotifier<AnimeDataClass> notifier;
  
  AnimeDataNotifier(
    this.id,
    this.notifier
  );
}