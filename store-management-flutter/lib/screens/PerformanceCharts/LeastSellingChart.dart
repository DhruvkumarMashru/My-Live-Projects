// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../controller/performance_controller.dart';
import '../../shared/constants.dart';

class LeastSellingChart extends GetWidget<PerformanceController> {
  const LeastSellingChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List<charts.Series<BarChartModel, String>> series = [
    //   charts.Series(
    //     id: "soldquantity",
    //     data: [],
    //     domainFn: (BarChartModel series, _) => series.productname,
    //     measureFn: (BarChartModel series, _) => series.soldquantity,
    //     colorFn: (BarChartModel series, _) => series.color,
    //   ),
    // ];

    return GetBuilder<PerformanceController>(builder: (controller) {
      final list =
          (controller.dashboardData?['leastSelling'] as List?)?.cast<dynamic>() ??
              const <dynamic>[];

      return controller.dashboardData == null
          ? Container(
              height: MediaQuery.of(context).size.height - 200,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                color: kprimaryColor,
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height - 200,
              padding: const EdgeInsets.all(5),
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: 60,
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<dynamic, String>>[
                  ColumnSeries<dynamic, String>(
                    dataSource: list,
                    xValueMapper: (dynamic row, _) =>
                        row['item_name']?.toString() ?? '',
                    yValueMapper: (dynamic row, _) =>
                        int.tryParse(row['sales']?.toString() ?? '') ?? 0,
                    name: 'Least Selling',
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            );
    });
  }
}

class BarChartModel {
  String productname;
  int soldquantity;

  BarChartModel({
    required this.productname,
    required this.soldquantity,
  });
}
