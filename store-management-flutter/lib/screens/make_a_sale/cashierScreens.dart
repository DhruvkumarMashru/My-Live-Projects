import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:store_management_modern/controller/login_controller.dart';
import 'package:store_management_modern/shared/roles.dart';
import 'makeSale.dart';

class CashierScreensPage extends StatelessWidget {
  const CashierScreensPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = Get.find<LoginController>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Cashier Screens".tr,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F1C2E), Color(0xFF243B55)],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, String>>>(
          future: loginController.listLocalUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF4FC3F7)));
            }
        
            final allUsers = snapshot.data ?? const [];
            final cashiers = allUsers.where(
              (u) => (u['role'] ?? AppRoles.employee) == AppRoles.employee || (u['role'] == AppRoles.cashier),
            );
        
            final list = cashiers.toList();
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.group_off_rounded, size: 64, color: Colors.white24),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "No Cashiers Found".tr,
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ask the manager to create employees first.".tr,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              );
            }
        
            return ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final cashier = list[index];
                final name = (cashier['name'] ?? '').trim();
                final email = cashier['email'] ?? '';
                final label = name.isEmpty ? email : name;
        
                return GestureDetector(
                  onTap: () {
                    Get.to(() => const MakeSalePage());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF162534),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF4FC3F7).withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.point_of_sale_rounded, color: Color(0xFF4FC3F7), size: 24),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Launch Make Sale Terminal".tr,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
