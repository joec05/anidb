import 'package:anime_list_app/global_files.dart';
import 'package:flutter/material.dart';

class ViewUserStatistics extends StatelessWidget {
  const ViewUserStatistics({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const _ViewUserStatisticsStateful();
  }
}

class _ViewUserStatisticsStateful extends StatefulWidget {
  const _ViewUserStatisticsStateful();

  @override
  State<_ViewUserStatisticsStateful> createState() => _ViewUserStatisticsStatefulState();
}

class _ViewUserStatisticsStatefulState extends State<_ViewUserStatisticsStateful> with SingleTickerProviderStateMixin{
  late TabController _tabController;
  late UserStatisticsController controller;

  @override void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller = UserStatisticsController(context);
    controller.initializeController();
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
        leading: defaultLeadingWidget(context),
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
          builder: (context){
            return TabBarView(
              controller: _tabController,
              children: [
                ListenableBuilder(
                  listenable: Listenable.merge([
                    controller.isLoading,
                    controller.userAnimeStatistics,
                    controller.animeBarChartData,
                  ]), 
                  builder: (context, child) {
                    bool isLoadingValue = controller.isLoading.value;
                    UserAnimeStatisticsClass userAnimeStatistics = controller.userAnimeStatistics.value;
                    List<BarChartClass> animeBarChartData = controller.animeBarChartData.value;

                    if(isLoadingValue) {
                      return shimmerSkeletonWidget(
                        CustomUserAnimeStatsWidget(
                          userAnimeStats: userAnimeStatistics, 
                          barChartData: animeBarChartData, 
                          absorberContext: context,
                          skeletonMode: true,
                          key: UniqueKey()
                        ),
                      );
                    }
                    
                    return CustomUserAnimeStatsWidget(
                      userAnimeStats: userAnimeStatistics, 
                      barChartData: animeBarChartData, 
                      absorberContext: context,
                      skeletonMode: false,
                      key: UniqueKey()
                    );
                  }
                ),
                ListenableBuilder(
                  listenable: Listenable.merge([
                    controller.isLoading2, 
                    controller.userMangaStatistics,
                    controller.mangaBarChartData
                  ]), 
                  builder: (context, child) {
                    bool isLoadingValue2 = controller.isLoading2.value;
                    UserMangaStatisticsClass userMangaStatistics = controller.userMangaStatistics.value;
                    List<BarChartClass> mangaBarChartData = controller.mangaBarChartData.value;

                    if(isLoadingValue2) {
                      return shimmerSkeletonWidget(
                        CustomUserMangaStatsWidget(
                          userMangaStats: userMangaStatistics, 
                          barChartData: mangaBarChartData, 
                          absorberContext: context,
                          skeletonMode: true,
                          key: UniqueKey()
                        ),
                      );
                    }

                    return CustomUserMangaStatsWidget(
                      userMangaStats: userMangaStatistics, 
                      barChartData: mangaBarChartData, 
                      absorberContext: context,
                      skeletonMode: false,
                      key: UniqueKey()
                    );                      
                  }
                )
              ]
            );
          }
        )
      )
    );
  }

}