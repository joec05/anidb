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

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: ListView(
        children: [
          for(int i = 0; i < controller.notifiers.length; i++)
          ref.watch(controller.notifiers[i]).when(
            data: (data) => CustomHomeFrontDisplay(
              label: data.label,
              displayType: data.displayType, 
              dataList: data.dataList,
              isLoading: false,
              key: UniqueKey(),
            ),
            error: (obj, stackTrace) => DisplayErrorWidget(displayText: obj.toString()), 
            loading: () => Builder(
              builder: (context) {
                HomeFrontDisplayModel data = context.read(controller.notifiers[i]).value ?? HomeFrontDisplayModel(description[i], AnimeBasicDisplayType.season, List.filled(10, AnimeDataClass.fetchNewInstance(-1)));
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
        ]
      )
    );
  }
  
  @override
  bool get wantKeepAlive => true;

}