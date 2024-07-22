import 'package:anidb/global_files.dart';
import 'package:flutter/material.dart';

class CustomUserAnimeStatsWidget extends StatefulWidget {
  final UserAnimeStatisticsClass userAnimeStats;
  final List<BarChartClass> barChartData;
  final BuildContext absorberContext;
  final bool skeletonMode;

  const CustomUserAnimeStatsWidget({
    super.key,
    required this.userAnimeStats,
    required this.barChartData,
    required this.absorberContext,
    required this.skeletonMode
  });

  @override
  State<CustomUserAnimeStatsWidget> createState() => CustomUserAnimeStatsWidgetState();
}

class CustomUserAnimeStatsWidgetState extends State<CustomUserAnimeStatsWidget> with AutomaticKeepAliveClientMixin{
  late UserAnimeStatisticsClass userAnimeStats;
  late List<BarChartClass> barChartData;

  @override void initState(){
    super.initState();
    userAnimeStats = widget.userAnimeStats;
    barChartData = widget.barChartData;
  }

  @override void dispose(){
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    double fullWidth = getScreenWidth() - defaultHorizontalPadding * 2;
    if(!widget.skeletonMode){
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(widget.absorberContext)
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: defaultHorizontalPadding,
                vertical: defaultVerticalPadding
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: getScreenHeight() * 0.015
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: fullWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Total', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${userAnimeStats.total}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              width: fullWidth * 0.05
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Episodes watched', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${userAnimeStats.totalEpisodes}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ), 
                          ]
                        )
                      )
                    ]
                  ),
                  SizedBox(
                    height: getScreenHeight() * 0.01
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: fullWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Mean score', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text(userAnimeStats.meanScore.toStringAsFixed(1), style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              width: fullWidth * 0.05
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Watching', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${userAnimeStats.watching}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            )
                          ]
                        )
                      )
                    ]
                  ),
                  SizedBox(
                    height: getScreenHeight() * 0.01
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: fullWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Planning', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${userAnimeStats.planToWatch}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              width: fullWidth * 0.05
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Completed', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${userAnimeStats.completed}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                          ]
                        )
                      )
                    ]
                  ),
                  SizedBox(
                    height: getScreenHeight() * 0.01
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: fullWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('On Hold', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${userAnimeStats.onHold}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              width: fullWidth * 0.05
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Dropped', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  Text('${userAnimeStats.dropped}', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.925,
                                    fontWeight: FontWeight.w600
                                  ))
                                ],
                              ),
                            ),
                          ]
                        )
                      )
                    ]
                  ),
                  SizedBox(
                    height: getScreenHeight() * 0.035
                  ),
                  for(int i = 0; i < barChartData.length; i++)
                  Column(
                    children: [
                      SizedBox(
                        height: getScreenHeight() * 0.025
                      ),
                      Text(barChartData[i].title, style: TextStyle(
                        fontSize: defaultTextFontSize
                      )),
                      SizedBox(
                        height: getScreenHeight() * 0.015
                      ),
                      VerticalBarChartWidget(
                        bardata: barChartData[i].model,
                        legend: barChartData[i].legend,
                        sum: barChartData[i].totalValue
                      ),
                      SizedBox(
                        height: getScreenHeight() * 0.025
                      ),
                    ],
                  )
                ],
              )
            )
          )
        ]
      );
    }else{
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(widget.absorberContext)
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: defaultHorizontalPadding,
                vertical: defaultVerticalPadding
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: getScreenHeight() * 0.015
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: fullWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Total', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text(''),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: fullWidth * 0.05
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Episodes watched', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text(''),
                                ],
                              ),
                            ), 
                          ]
                        )
                      )
                    ]
                  ),
                  SizedBox(
                    height: getScreenHeight() * 0.01
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: fullWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Mean score', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text(''),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: fullWidth * 0.05
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Watching', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text(''),
                                ],
                              ),
                            )
                          ]
                        )
                      )
                    ]
                  ),
                  SizedBox(
                    height: getScreenHeight() * 0.01
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: fullWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Planning', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text(''),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: fullWidth * 0.05
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Completed', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text(''),
                                ],
                              ),
                            ),
                          ]
                        )
                      )
                    ]
                  ),
                  SizedBox(
                    height: getScreenHeight() * 0.01
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: fullWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('On Hold', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text(''),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: fullWidth * 0.05
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyan.withOpacity(0.475),
                                borderRadius: const BorderRadius.all(Radius.circular(12.5))
                              ),
                              width: fullWidth * 0.475,
                              height: getScreenHeight() * 0.09,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Dropped', style: TextStyle(
                                    fontSize: defaultTextFontSize * 0.825,
                                    fontWeight: FontWeight.w400
                                  )),
                                  SizedBox(
                                    height: getScreenHeight() * 0.005,
                                  ),
                                  const Text(''),
                                ],
                              ),
                            ),
                          ]
                        )
                      )
                    ]
                  ),
                  SizedBox(
                    height: getScreenHeight() * 0.01675
                  ),
                  for(int i = 0; i < 3; i++)
                  Column(
                    children: [
                      SizedBox(
                        height: getScreenHeight() * 0.0125
                      ),
                      Text('', style: TextStyle(
                        fontSize: defaultTextFontSize
                      )),
                      SizedBox(
                        height: getScreenHeight() * 0.0075
                      ),
                      Container(
                        color: Colors.grey,
                        width: fullWidth,
                        height: getScreenHeight() * 0.5
                      ),
                      SizedBox(
                        height: getScreenHeight() * 0.0125
                      ),
                    ],
                  )
                ],
              )
            )
          )
        ]
      );
    }
  }
  
  @override
  bool get wantKeepAlive => true;
}