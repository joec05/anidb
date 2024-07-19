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

class _ProfilePageStatefulState extends ConsumerState<_ProfilePageStateful> with SingleTickerProviderStateMixin {
  late ProfileController controller;
  late UserStatisticsController statisticsController;
  late TabController _tabController;

  @override void initState() {
    super.initState();
     _tabController = TabController(length: 2, vsync: this);
    controller = ProfileController();
    controller.initialize();
    statisticsController = UserStatisticsController();
    statisticsController.initialize();
  }

  @override void dispose(){
    super.dispose();
    _tabController.dispose();
    controller.dispose();
    statisticsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, bool f) {
          return <Widget>[
            SliverToBoxAdapter(
              child: Builder(
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
              ),
            ),
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
            final statisticsNotifiers = statisticsController.myStatisticsNotifiers;
            List<AsyncValue<APIResponseModel>> statisticsProviders = List.generate(statisticsNotifiers.length, (i) => ref.watch(statisticsNotifiers[i]));
            return TabBarView(
              controller: _tabController,
              children: [                
                RefreshIndicator(
                  onRefresh: () => context.read(statisticsController.myStatisticsNotifiers[0].notifier).refresh(),
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
                  onRefresh: () => context.read(statisticsController.myStatisticsNotifiers[1].notifier).refresh(),
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