import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/controller/performance_controller.dart';
import 'package:store_management_modern/screens/PerformanceCharts/ShowStoreMovementChart.dart';
import '../PerformanceCharts/BestSellingChart.dart';
import '../PerformanceCharts/LeastSellingChart.dart';
import '../PerformanceCharts/LowStockProductsChart.dart';

class Dashboard extends GetWidget<PerformanceController> {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Dashboard".tr,
          style: GoogleFonts.inter(
            color: theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            // Date Picker Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                   Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("From".tr, style: GoogleFonts.inter(fontSize: 12, color: theme.hintColor)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _selectDate(context, isFrom: true),
                          child: GetBuilder<PerformanceController>(
                            builder: (controller) => _buildDateBadge(
                              context: context,
                              date: controller.dateTimeFrom ?? DateTime.now(),
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: theme.dividerColor, margin: const EdgeInsets.symmetric(horizontal: 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("To".tr, style: GoogleFonts.inter(fontSize: 12, color: theme.hintColor)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _selectDate(context, isFrom: false),
                          child: GetBuilder<PerformanceController>(
                            builder: (controller) => _buildDateBadge(
                              context: context,
                              date: controller.dateTimeTo ?? DateTime.now(),
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, "Store Movement"),
            const SizedBox(height: 12),
            _buildChartWrapper(context, const ShowStoreMovementChart()),

            const SizedBox(height: 32),
            _buildSectionHeader(context, "Best Selling Chart"),
            const SizedBox(height: 12),
            _buildChartWrapper(context, const BestSellingChart()),

            const SizedBox(height: 32),
            _buildSectionHeader(context, "Least Selling Chart"),
            const SizedBox(height: 12),
            _buildChartWrapper(context, const LeastSellingChart()),

            const SizedBox(height: 32),
            _buildSectionHeader(context, "Low Stock Products"),
            const SizedBox(height: 12),
            _buildChartWrapper(context, const LowStockProductsChart()),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBadge({required BuildContext context, required DateTime date, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            "${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}",
            style: GoogleFonts.inter(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title.tr,
      style: GoogleFonts.inter(
        color: theme.textTheme.bodyLarge?.color,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildChartWrapper(BuildContext context, Widget chart) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: chart,
    );
  }

  void _selectDate(BuildContext context, {required bool isFrom}) {
    final theme = Theme.of(context);
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2005),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              surface: theme.cardColor,
            ),
          ),
          child: child!,
        );
      },
    ).then((value) {
      if (value != null) {
        if (isFrom) {
          controller.setDateFrom(value);
        } else {
          controller.setDateTo(value);
        }
        controller.getDashBoardData(
          to: controller.dateTimeTo ?? DateTime.now(),
          from: controller.dateTimeFrom ?? DateTime.now(),
        );
      }
    });
  }
}
