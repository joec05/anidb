import 'dart:async';
import 'package:anime_list_app/models/api/api_response_model.dart';
import 'package:anime_list_app/repository/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserStatisticsController {
  BuildContext context;
  late List<AutoDisposeAsyncNotifierProvider<MyStatisticsNotifier, APIResponseModel>> myStatisticsNotifiers = [];

  UserStatisticsController(
    this.context
  );

  bool get mounted => context.mounted;

  void initializeController() {
    myStatisticsNotifiers = [
      AsyncNotifierProvider.autoDispose<MyStatisticsNotifier, APIResponseModel>(
        () => MyStatisticsNotifier(context, 'anime')
      ),
      AsyncNotifierProvider.autoDispose<MyStatisticsNotifier, APIResponseModel>(
        () => MyStatisticsNotifier(context, 'manga')
      )
    ];
  }

  void dispose() {
  }

}

class MyStatisticsNotifier extends AutoDisposeAsyncNotifier<APIResponseModel>{
  final BuildContext context;
  final String dataType;
  late ProfileRepository profileRepository;
  APIResponseModel statsData = APIResponseModel(null, null);

  MyStatisticsNotifier(this.context, this.dataType);

  @override
  FutureOr<APIResponseModel> build() async {
    state = const AsyncLoading();
    profileRepository = ProfileRepository(context);
    APIResponseModel response;
    if(dataType == 'anime') {
      response = await profileRepository.fetchMyAnimeStatistics();
    } else {
      response = await profileRepository.fetchMyMangaStatistics();
    }
    if(response.error != null) {
      state = AsyncError(response.error!.object, response.error!.stackTrace);
      throw Exception(response.error!.object);
    } else {
      statsData = response; 
      state = AsyncData(statsData);
    }
    return statsData;
  }

  Future<void> refresh() async => await build();
}