import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class AnimeDataNotifier {
  int id;
  ValueNotifier<AnimeDataClass> notifier;
  
  AnimeDataNotifier(
    this.id,
    this.notifier
  );
}