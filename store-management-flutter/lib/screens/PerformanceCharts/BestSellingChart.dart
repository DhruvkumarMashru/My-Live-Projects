// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_management_modern/controller/performance_controller.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../shared/constants.dart';

class BestSellingChart extends GetWidget<PerformanceController> {
  const BestSellingChart({Key? key}) : super(key: key);
  // final List<BarChartModel> data = [
  //   BarChartModel(
  //     productname: "product1",
  //     soldquantity: 250,
  //     color: charts.ColorUtil.fromDartColor(Colors.blueGrey),
  //   ),
  //   BarChartModel(
  //     productname: "product2",
  //     soldquantity: 300,
  //     color: charts.ColorUtil.fromDartColor(Colors.red),
  //   ),
  //   BarChartModel(
  //     productname: "product3",
  //     soldquantity: 100,
  //     color: charts.ColorUtil.fromDartColor(Colors.green),
  //   ),
  //   BarChartModel(
  //     productname: "product4",
  //     soldquantity: 450,
  //     color: charts.ColorUtil.fromDartColor(Colors.yellow),
  //   ),
  //   BarChartModel(
  //     productname: "product5",
  //     soldquantity: 300,
  //     color: charts.ColorUtil.fromDartColor(Colors.blue),
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PerformanceController>(
      builder: (controller) {
        final list =
            (controller.dashboardData?['bestSelling'] as List?)?.cast<dynamic>() ??
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
                padding: const EdgeInsets.all(5),
                height: MediaQuery.of(context).size.height - 200,
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
                      name: 'Best Selling',
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                    ),
                  ],
                ),
              );
      },
    );
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
