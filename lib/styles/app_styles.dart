import 'package:anime_list_app/appdata/global_library.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vertical_barchart/vertical-barchart.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:vertical_barchart/vertical-legend.dart';

BoxDecoration defaultAppBarDecoration = const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.fromARGB(255, 76, 153, 106), Color.fromARGB(255, 185, 82, 13)
    ],
    stops: [
      0.25, 0.6
    ],
  ),
);

Widget defaultLeadingWidget(BuildContext context){
  return InkWell(
    splashFactory: InkRipple.splashFactory,
    onTap: () => context.mounted ? runDelay(() => Navigator.pop(context), 0) : (){},
    child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white)
  );
}

double defaultAppBarTitleSpacing = getScreenWidth() * 0.02;

double defaultHomeAppBarTitleSpacing = getScreenWidth() * 0.06;

double defaultTextFontSize = 15.5;

double defaultHorizontalPadding = getScreenWidth() * 0.02;

double defaultVerticalPadding = getScreenHeight() * 0.01;

Size animeGridDisplayWidgetSize = Size(
  getScreenWidth() * 0.425,
  getScreenHeight() * 0.4,
);

Size animeGridDisplayCoverSize = Size(
  getScreenWidth() * 0.425,
  getScreenHeight() * 0.3,
);

Size animeDisplayCoverSize = Size(
  getScreenWidth() * 0.325,
  getScreenHeight() * 0.25,
);

Size animeDetailDisplayCoverSize = Size(
  getScreenWidth() * 0.475,
  getScreenHeight() * 0.4,
);

VerticalBarchart generateBarChart(List<VBarChartModel> bardata, List<Vlegend> legend, double sum){
  return VerticalBarchart(
    maxX: sum,
    data: bardata,
    showLegend: true,
    alwaysShowDescription: false,
    showBackdrop: true,
    legend: legend,
    labelSizeFactor: 0.15,
  );
}

Widget shimmerSkeletonWidget(Widget child){
  return Shimmer.fromColors(
    baseColor: Colors.grey.withOpacity(0.5),
    highlightColor: const Color.fromARGB(179, 167, 155, 155),
    child: child
  );
}