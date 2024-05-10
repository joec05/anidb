import 'package:flutter/material.dart';
import 'package:vertical_barchart/vertical-barchart.dart';
import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:vertical_barchart/vertical-legend.dart';

class VerticalBarChartWidget extends StatelessWidget {

  final List<VBarChartModel> bardata;
  final List<Vlegend> legend; 
  final double sum;

  const VerticalBarChartWidget({
    super.key, 
    required this.bardata,
    required this.legend,
    required this.sum
  });

  @override
  Widget build(BuildContext context) {
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
}