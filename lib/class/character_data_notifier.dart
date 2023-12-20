import 'package:anime_list_app/class/character_data_class.dart';
import 'package:flutter/material.dart';

class CharacterDataNotifier{
  final int id;
  ValueNotifier<CharacterDataClass> notifier;

  CharacterDataNotifier(
    this.id,
    this.notifier
  );
}