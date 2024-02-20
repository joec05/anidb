import 'package:anime_list_app/global_files.dart';
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
  late ProfileController controller;

  @override void initState(){
    super.initState();
    controller = ProfileController(context);
    controller.initializeController();
  }

  @override void dispose(){
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder(
      valueListenable: controller.isLoading,
      builder: (context, isLoadingValue, child) {

        if(isLoadingValue) {
          return shimmerSkeletonWidget(
            CustomProfileDisplay(
              userData: UserDataClass.fetchNewInstance(-1), 
              skeletonMode: true,
              key: UniqueKey()
            )
          );
        }

        if(authRepo.currentUserData == null){
          return Container();
        }

        return ValueListenableBuilder(
          valueListenable: authRepo.currentUserData!.notifier, 
          builder: (context, userData, child){
            return CustomProfileDisplay(
              userData: userData, 
              skeletonMode: false,
              key: UniqueKey()
            );
          }
        );
      }
    );
  }
  
  @override
  bool get wantKeepAlive => true;

}