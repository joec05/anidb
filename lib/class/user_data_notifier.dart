import 'package:anime_list_app/class/user_data_class.dart';
import 'package:flutter/material.dart';

class UserDataNotifier {
  int id;
  ValueNotifier<UserDataClass> notifier;
  
  UserDataNotifier(
    this.id,
    this.notifier
  );
}