import 'package:anidb/global_files.dart';
import 'package:flutter/material.dart';

class UserDataNotifier {
  int id;
  ValueNotifier<UserDataClass> notifier;
  
  UserDataNotifier(
    this.id,
    this.notifier
  );
}