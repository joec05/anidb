import 'package:flutter/material.dart';
import 'package:vertical_barchart/vertical-barchart.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:vertical_barchart/vertical-legend.dart';

VerticalBarchart generateBarChart(BuildContext context, List<VBarChartModel> bardata, List<Vlegend> legend, double sum){
  return VerticalBarchart(
    maxX: sum,
    data: bardata,
    showLegend: true,
    alwaysShowDescription: false,
    showBackdrop: true,
    legend: legend,
    labelSizeFactor: 0.15,
    background: Theme.of(context).colorScheme.background,
  );
}