import 'package:anidb_app/global_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewUserStatistics extends ConsumerWidget {
  const ViewUserStatistics({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ViewUserStatisticsStateful();
  }
}

class _ViewUserStatisticsStateful extends ConsumerStatefulWidget {
  const _ViewUserStatisticsStateful();

  @override
  ConsumerState<_ViewUserStatisticsStateful> createState() => _ViewUserStatisticsStatefulState();
}

class _ViewUserStatisticsStatefulState extends ConsumerState<_ViewUserStatisticsStateful> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  late UserStatisticsController controller;

  @override void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller = UserStatisticsController();
    controller.initialize();
  }

  @override void dispose(){
    super.dispose();
    _tabController.dispose();
    controller.dispose();
    
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: const AppBarWidget(),
        flexibleSpace: Container(
          decoration: defaultAppBarDecoration
        ),
        title: const Text('Statistics'), titleSpacing: defaultAppBarTitleSpacing,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, bool f) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                floating: true, 
                expandedHeight: 50,
                pinned: true,
                automaticallyImplyLeading: false,
                bottom: TabBar(
                  onTap: (selectedIndex) {
                  },
                  isScrollable: false,
                  controller: _tabController,
                  labelColor: Colors.grey,
                  indicatorColor: Colors.orange,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 3.0,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Anime'),
                    Tab(text: 'Manga'),
                  ],
                )                           
            ),
            )
          ];
        },
        body: Builder(
          builder: (context) {
            final statisticsNotifiers = controller.myStatisticsNotifiers;
            List<AsyncValue<APIResponseModel>> statisticsProviders = List.generate(statisticsNotifiers.length, (i) => ref.watch(statisticsNotifiers[i]));
            return TabBarView(
              controller: _tabController,
              children: [                
                RefreshIndicator(
                  onRefresh: () => context.read(controller.myStatisticsNotifiers[0].notifier).refresh(),
                  child: statisticsProviders[0].when(
                    data: (data) => CustomUserAnimeStatsWidget(
                      userAnimeStats: data.data, 
                      barChartData: data.data2, 
                      absorberContext: context,
                      skeletonMode: false,
                      key: UniqueKey()
                    ),
                    error: (obj, stackTrace) => DisplayErrorWidget(displayText: obj.toString()),
                    loading: () => ShimmerWidget(
                      child: CustomUserAnimeStatsWidget(
                        userAnimeStats: UserAnimeStatisticsClass.generateNewInstance(), 
                        barChartData: const [], 
                        absorberContext: context,
                        skeletonMode: true,
                        key: UniqueKey()
                      ),
                    )
                  ),
                ),
                RefreshIndicator(
                  onRefresh: () => context.read(controller.myStatisticsNotifiers[1].notifier).refresh(),
                  child: statisticsProviders[1].when(
                    data: (data) => CustomUserMangaStatsWidget(
                      userMangaStats: data.data, 
                      barChartData: data.data2, 
                      absorberContext: context,
                      skeletonMode: false,
                      key: UniqueKey()
                    ),
                    error: (obj, stackTrace) => DisplayErrorWidget(displayText: obj.toString()),
                    loading: () => ShimmerWidget(
                      child: CustomUserMangaStatsWidget(
                        userMangaStats: UserMangaStatisticsClass.generateNewInstance(), 
                        barChartData: const [], 
                        absorberContext: context,
                        skeletonMode: true,
                        key: UniqueKey()
                      ),
                    )
                  ),
                ),
              ]
            );
          }
        )
      )
    );
  }

}