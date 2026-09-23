import 'package:customer/app/cart_screen/cart_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  RxList<OrderModel> allList = <OrderModel>[].obs;
  RxList<OrderModel> inProgressList = <OrderModel>[].obs;
  RxList<OrderModel> deliveredList = <OrderModel>[].obs;
  RxList<OrderModel> rejectedList = <OrderModel>[].obs;
  RxList<OrderModel> cancelledList = <OrderModel>[].obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getOrder();
  }

  Future<void> getOrder() async {
    if (Constant.userModel != null) {
      await FireStoreUtils.getAllOrder().then((value) {
        isLoading.value = true;
        allList.value = value;

        rejectedList.value = allList.where((p0) => p0.status == Constant.orderRejected).toList();
        inProgressList.value =
            allList.where((p0) => p0.status == Constant.orderAccepted || p0.status == Constant.driverPending || p0.status == Constant.orderShipped || p0.status == Constant.orderInTransit).toList();

        deliveredList.value = allList.where((p0) => p0.status == Constant.orderCompleted).toList();
        cancelledList.value = allList.where((p0) => p0.status == Constant.orderCancelled).toList();
      });
    }

    isLoading.value = false;
  }

  final CartProvider cartProvider = CartProvider();

  void addToCart({required CartProductModel cartProductModel}) {
    cartProvider.addToCart(Get.context!, cartProductModel, cartProductModel.quantity!);
    update();
  }

  /// True when AT LEAST ONE product from the order is still available to buy.
  /// Previously this returned false if *any* single item was unpublished, which
  /// hid "Reorder" on most past orders as soon as one item was removed.
  Future<bool> hasAnyPublishedProduct(List<CartProductModel>? products) async {
    if (products == null || products.isEmpty) return false;
    for (final item in products) {
      final product = await FireStoreUtils.getProductById(item.id?.split('~').first ?? '');
      if (product != null && product.publish != false) {
        return true;
      }
    }
    return false;
  }

  /// Re-adds an order's still-available products to the cart, then opens the
  /// cart. Unavailable (deleted/unpublished) items are skipped and reported.
  Future<void> reorder(OrderModel orderModel) async {
    ShowToastDialog.showLoader("Please wait");
    int added = 0;
    int skipped = 0;

    for (final item in (orderModel.products ?? [])) {
      final product = await FireStoreUtils.getProductById(item.id?.split('~').first ?? '');
      if (product == null || product.publish == false) {
        skipped++;
        continue;
      }
      cartProvider.addToCart(Get.context!, item, item.quantity ?? 1);
      added++;
    }
    update();
    ShowToastDialog.closeLoader();

    if (added == 0) {
      ShowToastDialog.showToast("These items are no longer available.");
      return;
    }
    ShowToastDialog.showToast(skipped > 0 ? "$added item(s) added. $skipped no longer available." : "Items added to your cart");
    await Get.to(const CartScreen());
  }
}
