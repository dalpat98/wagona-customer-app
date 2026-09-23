import 'package:customer/constant/constant.dart';
import 'package:customer/models/favourite_item_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class FavouriteController extends GetxController {
  RxBool favouriteRestaurant = true.obs;
  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;
  RxList<VendorModel> favouriteVendorList = <VendorModel>[].obs;

  RxList<FavouriteItemModel> favouriteItemList = <FavouriteItemModel>[].obs;
  RxList<ProductModel> favouriteFoodList = <ProductModel>[].obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit

    super.onInit();
    getData();
  }

  // Kept identical to the previous inline subscription-gating logic, extracted so
  // both the restaurant and the item->vendor paths share one implementation.
  bool _vendorPassesSubscription(VendorModel value) {
    if (value.subscriptionTotalOrders == "-1") return true;
    if ((value.subscriptionExpiryDate != null && value.subscriptionExpiryDate!.toDate().isBefore(DateTime.now()) == false) || value.subscriptionPlan?.expiryDay == '-1') {
      return value.subscriptionTotalOrders != '0';
    }
    return false;
  }

  Future<void> getData() async {
    reset();
    if (Constant.userModel != null) {
      // Fetch both favourite lists concurrently instead of one after the other.
      final results = await Future.wait([
        FireStoreUtils.getFavouriteRestaurant(),
        FireStoreUtils.getFavouriteItem(),
      ]);
      favouriteList.value = results[0] as List<FavouriteModel>;
      favouriteItemList.value = results[1] as List<FavouriteItemModel>;

      final bool subscriptionActive = Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true;

      // ---- Favourite restaurants: fetch every vendor in PARALLEL (was N sequential reads) ----
      final vendors = await Future.wait(
        favouriteList.map((e) => FireStoreUtils.getVendorById(e.restaurantId.toString())),
      );
      final List<VendorModel> favouriteVendorData = [];
      for (final value in vendors) {
        if (value == null) continue;
        if (subscriptionActive && value.subscriptionPlan != null) {
          if (_vendorPassesSubscription(value)) favouriteVendorData.add(value);
        } else {
          favouriteVendorData.add(value);
        }
      }
      favouriteVendorData.sort((a, b) {
        final aOpen = Constant.statusCheckOpenORClose(vendorModel: a);
        final bOpen = Constant.statusCheckOpenORClose(vendorModel: b);
        if (aOpen == bOpen) return 0;
        return aOpen ? -1 : 1;
      });
      favouriteVendorList.value = favouriteVendorData;

      // ---- Favourite items: fetch every product in PARALLEL (was N sequential reads) ----
      final products = await Future.wait(
        favouriteItemList.map((e) => FireStoreUtils.getProductById(e.productId.toString())),
      );
      final publishedProducts = products.where((p) => p != null && p.publish == true).cast<ProductModel>().toList();

      if (subscriptionActive) {
        // Dedupe vendor lookups: many favourite items can share a vendor, so fetch
        // each unique vendor exactly once (was one nested read per item).
        final vendorIds = publishedProducts.map((p) => p.vendorID.toString()).toSet().toList();
        final vendorDocs = await Future.wait(vendorIds.map((id) => FireStoreUtils.getVendorById(id)));
        final Map<String, VendorModel> vendorCache = {};
        for (int i = 0; i < vendorIds.length; i++) {
          final v = vendorDocs[i];
          if (v != null) vendorCache[vendorIds[i]] = v;
        }
        for (final product in publishedProducts) {
          final vendorModel = vendorCache[product.vendorID.toString()];
          if (vendorModel?.subscriptionPlan != null && _vendorPassesSubscription(vendorModel!)) {
            favouriteFoodList.add(product);
          }
        }
      } else {
        favouriteFoodList.addAll(publishedProducts);
      }
    }
    List<ProductModel> favouriteFoodData = favouriteFoodList;
    List<VendorModel> favouriteVendorData = favouriteVendorList;
    favouriteFoodList.value = removeDuplicateFoods(favouriteFoodData);
    favouriteVendorList.value = removeDuplicateVendor(favouriteVendorData);
    isLoading.value = false;
  }

  List<ProductModel> removeDuplicateFoods(List<ProductModel> favouriteFoodList) {
    final seenIds = <String>{};
    return favouriteFoodList.where((food) {
      return seenIds.add(food.id!);
    }).toList();
  }

  List<VendorModel> removeDuplicateVendor(List<VendorModel> favouriteFoodVendor) {
    final seenIds = <String>{};
    return favouriteFoodVendor.where((food) {
      return seenIds.add(food.id!);
    }).toList();
  }

  void reset() {
    favouriteRestaurant.value = true;
    favouriteList.value = [];
    favouriteVendorList.value = [];
    favouriteItemList.value = [];
    favouriteFoodList.value = [];
    isLoading.value = true;
  }
}
