import 'package:anidb_app/global_files.dart';
import 'package:flutter/material.dart';

class MangaDataNotifier {
  int id;
  ValueNotifier<MangaDataClass> notifier;
  
  MangaDataNotifier(
    this.id,
    this.notifier
  );
}