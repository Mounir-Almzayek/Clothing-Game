import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/roster_controller.dart';

class StatisticsScreen extends StatelessWidget {
  StatisticsScreen({super.key});

  final RosterController controller = Get.find<RosterController>();

  bool showStats = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.indigo.shade600,
        elevation: 4,
        shadowColor: Colors.indigo.shade200,
      ),
      body: FutureBuilder<Map<int, int>>(
        future: controller.getUserStarDistribution(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          final barGroups = data.entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: Colors.indigo.shade600,
                  width: 30.w,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.r),
                    topRight: Radius.circular(4.r),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    toY: 0,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ],
            );
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 70.h),
              SizedBox(
                height: 300.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: BarChart(
                    BarChartData(
                      maxY: (data.values.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value % 2 != 0) return const SizedBox.shrink();
                              return Text(
                                '${value.toInt()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40.h,
                            getTitlesWidget: (value, meta) {
                              return Container(
                                margin: EdgeInsets.all(7.r),
                                child: Text(
                                  '${value.toInt()} ⭐',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          left: BorderSide(color: Colors.black54, width: 3.w),
                          bottom: BorderSide(color: Colors.black54, width: 3.h),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 8.r,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              ' مستخدمين ${rod.toY.toInt()}',
                              TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            );
                          },
                        ),
                      ),
                      barGroups: barGroups,
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 800),
                    swapAnimationCurve: Curves.easeOutCubic,
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              AnimatedSlide(
                offset: showStats ? Offset.zero : const Offset(0, 0.3),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StatTile(
                        title: 'الإجمالي',
                        value: data.values.reduce((a, b) => a + b).toString(),
                      ),
                      StatTile(
                        title: 'أعلى قيمة',
                        value: data.values.reduce((a, b) => a > b ? a : b).toString(),
                      ),
                      StatTile(
                        title: 'المتوسط',
                        value: (data.values.reduce((a, b) => a + b) / data.length)
                            .toStringAsFixed(1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget StatTile({required String title, required String value}) {
  return Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
      Text(
        title,
        style: TextStyle(fontSize: 14.sp, color: Colors.black54),
      ),
    ],
  );
}
