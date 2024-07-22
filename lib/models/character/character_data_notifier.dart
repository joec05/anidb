import 'package:anidb/global_files.dart';
import 'package:flutter/material.dart';

class CharacterDataNotifier{
  final int id;
  ValueNotifier<CharacterDataClass> notifier;

  CharacterDataNotifier(
    this.id,
    this.notifier
  );
}