import 'dart:async';
import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileController {
  final BuildContext context;
  late AutoDisposeAsyncNotifierProvider<ProfileNotifier, UserDataClass> profileNotifier;

  ProfileController (
    this.context
  );

  bool get mounted => context.mounted;

  void initializeController() {
    profileNotifier = AsyncNotifierProvider.autoDispose<ProfileNotifier, UserDataClass>(
      () => ProfileNotifier(context)
    );
  }

  void dispose(){
  }  
}

class ProfileNotifier extends AutoDisposeAsyncNotifier<UserDataClass> {
  final BuildContext context;
  late ProfileRepository profileRepository;
  UserDataClass myUserData = UserDataClass.fetchNewInstance(-1);

  ProfileNotifier(this.context);
  
  @override
  FutureOr<UserDataClass> build() async {
    state = const AsyncLoading();
    profileRepository = ProfileRepository(context);
    APIResponseModel response = await profileRepository.fetchMyProfileData();
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      myUserData = response.data;
      state = AsyncData(myUserData);
    }
    return myUserData;
  }

  Future<void> refresh() async => await build();
}