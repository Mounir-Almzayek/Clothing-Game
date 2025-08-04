import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shirt_base/presentation/pages/stages_screen.dart';
import 'package:shirt_base/presentation/pages/statistics_screen.dart';
import '../../controllers/roster_controller.dart';
import '../../data/models/user.dart';

class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RosterController controller = Get.put(RosterController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.indigo.shade600,
        elevation: 4,
        shadowColor: Colors.indigo.shade200,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            color: Colors.white,
            onPressed: () => Get.to(() => StatisticsScreen()),
          ),
        ],
      ),
      body: Obx(() {
        final status = controller.usersManager.value;
        if (status.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (status.hasError) {
          return Center(
            child: Text('Error loading users: ${status.error}'),
          );
        }
        final List<User> users = status.value ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('لا يوجد مستخدمون بعد.', style: TextStyle(color: Colors.black54),));
        }
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Text(
                    'لائحة الأطفال',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600,color: Colors.black),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Obx(() => Icon(
                      controller.sortMode.value == SortMode.byStars
                          ? Icons.star
                          : Icons.sort_by_alpha,
                      color: Theme.of(context).primaryColor,
                    )),
                    onPressed: controller.toggleSortMode,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(8.r),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Dismissible(
                      key: Key(user.id.toString()),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) {
                        controller.deleteUser(user.id);
                        Get.snackbar('Deleted', 'User ${user.name} deleted');
                      },
                      background: Container(
                        color: Colors.red.shade900,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          controller.selectedUser.value = user;
                          Get.to(() => const StagesScreen());
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            title: Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: FutureBuilder<int>(
                              future: controller.getCompletedStars(user.id),
                              builder: (context, snapshot) {
                                final stars = snapshot.data ?? 0;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                    3,
                                        (i) => Icon(
                                      i < stars ? Icons.star : Icons.star_border,
                                      size: 20.sp,
                                      color: Colors.amber,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        onPressed: () {
          String name = '';
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              title: const Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  'إضافة مستخدم',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              content: TextField(
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'ادخل الاسم',
                  hintStyle: const TextStyle(color: Colors.black54),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
                onChanged: (value) => name = value,
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                IconButton(
                  tooltip: 'إلغاء',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close, color: Colors.black),
                ),
                IconButton(
                  tooltip: 'إضافة',
                  onPressed: () {
                    if (name.trim().isNotEmpty) {
                      controller.addUser(
                        User(name: name.trim()),
                        onSuccess: (_) => Navigator.of(dialogContext).pop(),
                        onError: (e) =>
                            Get.snackbar('خطأ', 'فشل في الإضافة: $e'),
                      );
                    }
                  },
                  icon: const Icon(Icons.check, color: Colors.black),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.indigo.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.person_add_alt_1, size: 28, color: Colors.white),
      ),
    );
  }
}
