import 'package:anime_list_app/global_files.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfilePageStateful();
  }
}

class _ProfilePageStateful extends StatefulWidget {
  const _ProfilePageStateful();

  @override
  State<_ProfilePageStateful> createState() => _ProfilePageStatefulState();
}

class _ProfilePageStatefulState extends State<_ProfilePageStateful> with AutomaticKeepAliveClientMixin{
  bool isLoading = true;

  @override void initState(){
    super.initState();
    fetchAnimeList();
  }

  @override void dispose(){
    super.dispose();
  }

  void fetchAnimeList() async{
    var res = await dio.get(
      '$malApiUrl/users/@me',
      options: Options(
        headers: {
          'Authorization': await generateAuthHeader()
        },
      )
    );
    var data = res.data;
    appStateClass.currentUserData = UserDataNotifier(
      data['id'], 
      ValueNotifier(UserDataClass.fromMap(data))
    );
    isLoading = false;
    if(mounted){
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(!isLoading){
      if(appStateClass.currentUserData == null){
        return Container();
      }
      return ValueListenableBuilder(
        valueListenable: appStateClass.currentUserData!.notifier, 
        builder: (context, userData, child){
          return CustomProfileDisplay(
            userData: userData, 
            skeletonMode: false,
            key: UniqueKey()
          );
        }
      );
    }else{
      return shimmerSkeletonWidget(
        CustomProfileDisplay(
          userData: UserDataClass.fetchNewInstance(-1), 
          skeletonMode: true,
          key: UniqueKey()
        )
      );
    }
  }
  
  @override
  bool get wantKeepAlive => true;

}