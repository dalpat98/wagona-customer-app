import 'package:customer/app/home_screen/category_restaurant_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/view_all_category_controller.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:customer/widget/translated_text.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ViewAllCategoryScreen extends StatelessWidget {
  const ViewAllCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: ViewAllCategoryController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
              centerTitle: false,
              titleSpacing: 0,
              title: TranslatedText(
                "Categories",
                style: TextStyle(
                  fontSize: 16,
                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                  fontFamily: AppThemeData.medium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 3.5 / 6, crossAxisSpacing: 6),
                      itemCount: controller.vendorCategoryModel.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        VendorCategoryModel vendorCategoryModel = controller.vendorCategoryModel[index];
                        return InkWell(
                          onTap: () {
                            Get.to(const CategoryRestaurantScreen(), arguments: {"vendorCategoryModel": vendorCategoryModel, "dineIn": false});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.primary50,
                                    shape: BoxShape.circle,
                                    boxShadow: themeChange.getThem() ? null : AppThemeData.cardShadow,
                                  ),
                                  child: ClipOval(
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: NetworkImageWidget(
                                          imageUrl: vendorCategoryModel.photo.toString(),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: TranslatedText(
                                    '${vendorCategoryModel.title}',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                      fontFamily: AppThemeData.semiBold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          );
        });
  }
}
