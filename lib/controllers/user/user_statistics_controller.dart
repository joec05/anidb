import 'dart:async';
import 'package:anime_list_app/models/api/api_response_model.dart';
import 'package:anime_list_app/repository/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserStatisticsController {
  late List<AutoDisposeAsyncNotifierProvider<MyStatisticsNotifier, APIResponseModel>> myStatisticsNotifiers = [];

  void initialize() {
    myStatisticsNotifiers = [
      AsyncNotifierProvider.autoDispose<MyStatisticsNotifier, APIResponseModel>(
        () => MyStatisticsNotifier('anime')
      ),
      AsyncNotifierProvider.autoDispose<MyStatisticsNotifier, APIResponseModel>(
        () => MyStatisticsNotifier('manga')
      )
    ];
  }

  void dispose() {
  }

}

class MyStatisticsNotifier extends AutoDisposeAsyncNotifier<APIResponseModel>{
  final String dataType;
  APIResponseModel statsData = APIResponseModel(null, null);

  MyStatisticsNotifier(this.dataType);

  @override
  FutureOr<APIResponseModel> build() async {
    state = const AsyncLoading();
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