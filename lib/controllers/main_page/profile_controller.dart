import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class ProfileController {
  BuildContext context;
  ValueNotifier<bool> isLoading = ValueNotifier(true);

  ProfileController (
    this.context
  );

  bool get mounted => context.mounted;

  void initializeController() {
    fetchAnimeList();
  }

  void dispose(){
    isLoading.dispose();
  }

  void fetchAnimeList() async{
    var res = await apiCallRepo.runAPICall(
      context,
      APICallType.get,
      malApiUrl,
      '$malApiUrl/users/@me',
      {}
    );
    if(res != null) {
      authRepo.currentUserData = UserDataNotifier(
        res['id'], 
        ValueNotifier(UserDataClass.fromMap(res))
      );
      if(mounted) {
        isLoading.value = false;
      }
    }
  }
}