import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ProfilePageStateful();
  }
}

class _ProfilePageStateful extends ConsumerStatefulWidget {
  const _ProfilePageStateful();

  @override
  ConsumerState<_ProfilePageStateful> createState() => _ProfilePageStatefulState();
}

class _ProfilePageStatefulState extends ConsumerState<_ProfilePageStateful> with AutomaticKeepAliveClientMixin{
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
    return Builder(
      builder: (context) {  
        AsyncValue<UserDataClass> viewProfileDataState = ref.watch(controller.profileNotifier);
        return RefreshIndicator(
          onRefresh: () => context.read(controller.profileNotifier.notifier).refresh(),
          child: viewProfileDataState.when(
            data: (data) => CustomProfileDisplay(
              userData: data, 
              skeletonMode: false,
              key: UniqueKey()
            ),
            error: (obj, stackTrace) => DisplayErrorWidget(displayText: obj.toString()),
            loading: () => ShimmerWidget(
              child: CustomProfileDisplay(
                userData: UserDataClass.fetchNewInstance(-1), 
                skeletonMode: true,
                key: UniqueKey()
              )
            )
          ),
        );
      }
    );
  }
  
  @override
  bool get wantKeepAlive => true;

}