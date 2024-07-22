import 'dart:async';
import 'package:anidb/global_files.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileController {
  late AutoDisposeAsyncNotifierProvider<ProfileNotifier, UserDataClass> profileNotifier;

  void initialize() {
    profileNotifier = AsyncNotifierProvider.autoDispose<ProfileNotifier, UserDataClass>(
      () => ProfileNotifier()
    );
  }

  void dispose(){
  }  
}

class ProfileNotifier extends AutoDisposeAsyncNotifier<UserDataClass> {
  UserDataClass myUserData = UserDataClass.fetchNewInstance(-1);
  
  @override
  FutureOr<UserDataClass> build() async {
    state = const AsyncLoading();
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