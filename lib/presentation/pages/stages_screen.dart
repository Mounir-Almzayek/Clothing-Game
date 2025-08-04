import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shirt_base/data/models/stage_status.dart';
import '../../controllers/roster_controller.dart';
import 'washing_machine_screen.dart';

class StagesScreen extends GetView<RosterController> {
  const StagesScreen({super.key});

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
        centerTitle: true,
        title: Obx(() {
          return FutureBuilder<int>(
            future: controller.getCompletedStars(controller.selectedUser.value!.id),
            builder: (context, snapshot) {
              final stars = snapshot.data ?? 0;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                      (i) => Icon(
                    i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 30.sp,
                    color: Colors.amber,
                  ),
                ),
              );
            },
          );
        }),
      ),
      body: ListView.builder(
        itemCount: controller.selectedUser.value!.progress.stages.length,
        itemBuilder: (context, index) {
          final stage = controller.selectedUser.value!.progress.stages[index];

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
            child: Stack(
              children: [
                Container(
                  height: 250.h,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(stage.frontImagePath),
                      fit: BoxFit.contain,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.grey.shade300,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(1),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16.w,
                  bottom: 20.h,
                  child: Text(
                    stage.name,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black12,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 2.r,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 3.w,
                  bottom: 0,
                  right: 3.w,
                  child: Container(
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                        color: Colors.grey.shade500,
                        width: 1.w,
                      ),
                    ),
                    child: Obx(() {
                      return LinearProgressIndicator(
                        value: controller.selectedUser.value!.progress
                            .stages[index].currentCount /
                            controller.selectedUser.value!.progress
                                .stages[index].targetCount,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          controller.selectedUser.value!.progress.stages[index]
                              .status ==
                              StageStatus.completed
                              ? Colors.green.shade800
                              : Colors.indigo.shade600,
                        ),
                      );
                    }),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      controller.selectStage(stage);
                      Get.to(() => const WashingMachineScreen());
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}