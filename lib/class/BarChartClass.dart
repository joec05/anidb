import 'package:vertical_barchart/vertical-barchartmodel.dart';
import 'package:vertical_barchart/vertical-legend.dart';

class BarChartClass{
  String title;
  List<VBarChartModel> model;
  List<Vlegend> legend;
  double totalValue;

  BarChartClass(
    this.title, 
    this.model, 
    this.legend,
    this.totalValue
  );
}