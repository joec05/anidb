import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _HomePageStateful();
  }
}

class _HomePageStateful extends ConsumerStatefulWidget {
  const _HomePageStateful();

  @override
  ConsumerState<_HomePageStateful> createState() => _HomePageStatefulState();
}

class _HomePageStatefulState extends ConsumerState<_HomePageStateful> with AutomaticKeepAliveClientMixin {
  late HomeController controller;

  @override void initState(){
    super.initState();
    controller = HomeController();
    controller.initialize();
  }

  @override void dispose(){
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    AsyncValue<List<HomeFrontDisplayModel>> viewAnimeDataState = ref.watch(controller.homeNotifier);

    return RefreshIndicator(
      onRefresh: () => context.read(controller.homeNotifier.notifier).refresh(),
      child: viewAnimeDataState.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, i) => CustomHomeFrontDisplay(
            label: data[i].label,
            displayType: data[i].displayType, 
            dataList: data[i].dataList,
            isLoading: false,
            key: UniqueKey(),
          ),
        ) ,
        error: (obj, stackTrace) => DisplayErrorWidget(displayText: obj.toString()), 
        loading: () => ListView.builder(
          itemCount: context.read(controller.homeNotifier.notifier).displayed.length,
          itemBuilder: (context, i) {
            HomeFrontDisplayModel data = context.read(controller.homeNotifier.notifier).displayed[i];
            return CustomHomeFrontDisplay(
              label: data.label,
              displayType: data.displayType, 
              dataList: data.dataList,
              isLoading: true,
              key: UniqueKey(),
            );
          }
        )
      ),
    );
  }
  
  @override
  bool get wantKeepAlive => true;

}