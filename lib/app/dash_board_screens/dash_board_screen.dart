import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/dash_board_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/translation_notifier.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: DashBoardController(),
        builder: (controller) {
          final bool isDark = themeChange.getThem();
          final List<_NavItemData> items = Constant.walletSetting == false
              ? const [
                  _NavItemData(assetIcon: "assets/icons/ic_home.svg", label: 'Home'),
                  _NavItemData(assetIcon: "assets/icons/ic_fav.svg", label: 'Favourites'),
                  _NavItemData(assetIcon: "assets/icons/ic_orders.svg", label: 'Orders'),
                  _NavItemData(assetIcon: "assets/icons/ic_profile.svg", label: 'Profile'),
                ]
              : const [
                  _NavItemData(assetIcon: "assets/icons/ic_home.svg", label: 'Home'),
                  _NavItemData(assetIcon: "assets/icons/ic_fav.svg", label: 'Favourites'),
                  _NavItemData(assetIcon: "assets/icons/ic_wallet.svg", label: 'Wallet'),
                  _NavItemData(assetIcon: "assets/icons/ic_orders.svg", label: 'Orders'),
                  _NavItemData(assetIcon: "assets/icons/ic_profile.svg", label: 'Profile'),
                ];

          return PopScope(
            canPop: controller.canPopNow.value,
            onPopInvoked: (didPop) {
              final now = DateTime.now();
              if (controller.currentBackPressTime == null || now.difference(controller.currentBackPressTime!) > const Duration(seconds: 2)) {
                controller.currentBackPressTime = now;
                controller.canPopNow.value = false;
                ShowToastDialog.showToast("Double press to exit");
                return;
              } else {
                controller.canPopNow.value = true;
              }
            },
            child: Scaffold(
              extendBody: true,
              body: controller.pageList.isEmpty ? const SizedBox() : controller.pageList[controller.selectedIndex.value],
              bottomNavigationBar: ValueListenableBuilder(
                  valueListenable: TranslationNotifier.refresh,
                  builder: (_, __, ___) {
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                        borderRadius: BorderRadius.circular(AppThemeData.radiusXl),
                        boxShadow: AppThemeData.floatShadow,
                        border: Border.all(
                          color: isDark ? AppThemeData.grey800 : AppThemeData.grey100,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(items.length, (index) {
                          final bool selected = controller.selectedIndex.value == index;
                          return _NavItem(
                            data: items[index],
                            selected: selected,
                            isDark: isDark,
                            onTap: () {
                              if (index == 0) {
                                Get.put(DashBoardController());
                              }
                              controller.selectedIndex.value = index;
                            },
                          );
                        }),
                      ),
                    );
                  }),
            ),
          );
        });
  }
}

class _NavItemData {
  final String assetIcon;
  final String label;
  const _NavItemData({required this.assetIcon, required this.label});
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({required this.data, required this.selected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color inactive = isDark ? AppThemeData.grey400 : AppThemeData.grey500;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: selected ? 14 : 10, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppThemeData.primaryGradient : null,
          borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
          boxShadow: selected ? AppThemeData.primaryGlow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              data.assetIcon,
              height: 22,
              width: 22,
              colorFilter: ColorFilter.mode(
                selected ? AppThemeData.grey50 : inactive,
                BlendMode.srcIn,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 82),
                child: Text(
                  data.label.tr,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppThemeData.bold,
                    fontSize: 12.5,
                    color: AppThemeData.grey50,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
