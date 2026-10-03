// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../controller/performance_controller.dart';
import '../../shared/constants.dart';

class LowStockProductsChart extends StatelessWidget {
  const LowStockProductsChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PerformanceController>(builder: (controller) {
      final list =
          (controller.dashboardData?['lowStock'] as List?)?.cast<dynamic>() ??
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
                        int.tryParse(row['stock_quantity']?.toString() ?? '') ??
                            0,
                    name: 'Low Stock',
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
  int quantity;

  BarChartModel({
    required this.productname,
    required this.quantity,
  });
}
