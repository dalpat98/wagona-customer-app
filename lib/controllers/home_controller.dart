import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/dash_board_controller.dart';
import 'package:customer/models/BannerModel.dart';
import 'package:customer/models/advertisement_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/story_model.dart';
import 'package:customer/models/tax_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeController extends GetxController {
  final DashBoardController dashBoardController = Get.find<DashBoardController>();
  final CartProvider cartProvider = CartProvider();

  RxBool isLoading = true.obs;
  RxBool isListView = true.obs;
  RxBool isPopular = true.obs;
  RxString selectedOrderTypeValue = "Delivery".tr.obs;

  final Rx<PageController> pageController = PageController(viewportFraction: 0.877).obs;
  final Rx<PageController> pageBottomController = PageController(viewportFraction: 0.877).obs;
  final RxInt currentPage = 0.obs;
  final RxInt currentBottomPage = 0.obs;

  late TabController tabController;

  // 🔹 Caching & reactive data
  final RxList<VendorCategoryModel> vendorCategoryModel = <VendorCategoryModel>[].obs;
  final RxList<VendorModel> allNearestRestaurant = <VendorModel>[].obs;
  final RxList<VendorModel> newArrivalRestaurantList = <VendorModel>[].obs;
  final RxList<VendorModel> popularRestaurantList = <VendorModel>[].obs;
  final RxList<VendorModel> couponRestaurantList = <VendorModel>[].obs;
  final RxList<AdvertisementModel> advertisementList = <AdvertisementModel>[].obs;
  final RxList<CouponModel> couponList = <CouponModel>[].obs;
  final RxList<StoryModel> storyList = <StoryModel>[].obs;
  final RxList<BannerModel> bannerModel = <BannerModel>[].obs;
  final RxList<BannerModel> bannerBottomModel = <BannerModel>[].obs;
  final RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;

  StreamSubscription? _cartSubscription;
  StreamSubscription? _restaurantSubscription;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  Future<void> getData() async {
    isLoading.value = true;
    selectedOrderTypeValue.value = Preferences.getString(Preferences.foodDeliveryType, defaultValue: "Delivery");
    await Future.wait([
      getTaxList(),
      getVendorCategory(),
      getZone(),
      getCartData(),
    ]);
    _listenForRestaurants(); // 🔹 Stream listens in background
  }

  Future<void> getTaxList() async {
    await FireStoreUtils.getTaxList().then(
      (value) {
        if (value != null) {
          Constant.taxProductList = value.where((TaxModel taxModel) => taxModel.scope == "product").toList();
          Constant.orderProductTaxList = value.where((TaxModel taxModel) => taxModel.scope == "order").toList();
          Constant.driverDeliveryTaxList = value.where((TaxModel taxModel) => taxModel.scope == "delivery").toList();

          if (Constant.packagingChargeEnable == true) {
            Constant.packagingTaxList = value.where((TaxModel taxModel) => taxModel.scope == "packaging").toList();
          }
          if (Constant.platformFeeModel?.enable == true) {
            Constant.platformTaxList = value.where((TaxModel taxModel) => taxModel.scope == "platform").toList();
          }
        }
      },
    );
  }

  // ✅ Optimized cart listening
  Future<void> getCartData() async {
    _cartSubscription?.cancel();
    _cartSubscription = cartProvider.cartStream.listen((event) {
      cartItem
        ..clear()
        ..addAll(event);
      update(['cart']); // partial update only for cart widgets
    });
  }

  // ✅ Stream-based restaurant updates
  void _listenForRestaurants() {
    _restaurantSubscription?.cancel();
    _restaurantSubscription = FireStoreUtils.getAllNearestRestaurant().listen((restaurants) async {
      if (restaurants.isEmpty) {
        isLoading.value = false;
        return;
      }

      // Sort by open status and rating — precompute keys once per restaurant
      // instead of recomputing inside every comparison (O(n log n) calls).
      final Map<String?, bool> openStatus = {
        for (final r in restaurants) r.id: Constant.statusCheckOpenORClose(vendorModel: r),
      };
      final Map<String?, String> ratingKey = {
        for (final r in restaurants) r.id: Constant.calculateReview(reviewCount: r.reviewsCount.toString(), reviewSum: r.reviewsSum.toString()),
      };
      restaurants.sort((a, b) {
        final aOpen = openStatus[a.id] ?? false;
        final bOpen = openStatus[b.id] ?? false;
        if (aOpen == bOpen) {
          return (ratingKey[b.id] ?? "0").compareTo(ratingKey[a.id] ?? "0");
        }
        return aOpen ? -1 : 1;
      });

      // Batch update data lists (reduces rebuilds)
      allNearestRestaurant.assignAll(restaurants);
      newArrivalRestaurantList.assignAll(restaurants);
      newArrivalRestaurantList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
      //:: ${Constant.timestampToDate(vendorModel.createdAt!)}
      popularRestaurantList.assignAll(restaurants.take(10)); // only top 10
      Constant.restaurantList = allNearestRestaurant;

      // Filter categories used by restaurants
      final usedCategoryIds = restaurants.expand((v) => v.categoryID ?? []).toSet();
      vendorCategoryModel.retainWhere((cat) => usedCategoryIds.contains(cat.id));

      // Show the screen as soon as restaurants are ready — coupons, stories
      // and ads are reactive (Rx) lists, so their sections appear on their own
      // when the background fetch completes. No need to hold the loader.
      isLoading.value = false;
      _loadAdditionalData(restaurants);
    });
  }

  // ✅ Parallel fetching of coupons, stories, ads
  Future<void> _loadAdditionalData(List<VendorModel> restaurants) async {
    await Future.wait([
      _fetchCoupons(restaurants),
      _fetchStories(restaurants),
      if (Constant.isEnableAdsFeature) _fetchAds(restaurants),
    ]);
  }

  Future<void> _fetchCoupons(List<VendorModel> restaurants) async {
    final values = await FireStoreUtils.getHomeCoupon();
    final now = DateTime.now();

    couponList.clear();
    couponRestaurantList.clear();
    for (final c in values) {
      if (c.expiresAt!.toDate().isAfter(now)) {
        final match = restaurants.firstWhereOrNull((r) => r.id == c.resturantId);
        if (match != null) {
          couponList.add(c);
          couponRestaurantList.add(match);
        }
      }
    }
  }

  Future<void> _fetchStories(List<VendorModel> restaurants) async {
    final values = await FireStoreUtils.getStory();
    final vendorIds = restaurants.map((r) => r.id).toSet();

    storyList.assignAll(values.where((s) => vendorIds.contains(s.vendorID)).toList());
  }

  Future<void> _fetchAds(List<VendorModel> restaurants) async {
    final values = await FireStoreUtils.getAllAdvertisement();
    final vendorIds = restaurants.map((r) => r.id).toSet();

    advertisementList.assignAll(values.where((a) => vendorIds.contains(a.vendorId)).toList());
  }

  // ✅ Cached and parallel category + banner + favourite fetch
  Future<void> getVendorCategory() async {
    final results = await Future.wait([
      FireStoreUtils.getHomeVendorCategory(),
      FireStoreUtils.getHomeTopBanner(),
      FireStoreUtils.getHomeBottomBanner(),
    ]);

    vendorCategoryModel.assignAll(results[0] as List<VendorCategoryModel>);
    bannerModel.assignAll(results[1] as List<BannerModel>);
    bannerBottomModel.assignAll(results[2] as List<BannerModel>);

    // Favourites only drive the heart icons — fetch in the background instead
    // of blocking the initial load (favouriteList is reactive).
    getFavouriteRestaurant();
  }

  Future<void> getFavouriteRestaurant() async {
    // Guard on the LIVE Firebase session (getCurrentUid dereferences it) —
    // a cached userModel can outlive the auth session and crash otherwise.
    if (Constant.userModel == null || FirebaseAuth.instance.currentUser == null) return;
    try {
      final favs = await FireStoreUtils.getFavouriteRestaurant();
      favouriteList.assignAll(favs);
    } catch (e) {
      // Non-fatal — favourites only drive heart icons.
    }
  }

  // ✅ Optimized zone check
  Future<void> getZone() async {
    final zones = await FireStoreUtils.getZone();
    if (zones == null || zones.isEmpty) return;

    final current = LatLng(
      Constant.selectedLocation.location?.latitude ?? 0.0,
      Constant.selectedLocation.location?.longitude ?? 0.0,
    );

    for (final zone in zones) {
      final inside = Constant.isPointInPolygon(current, zone.area!);
      Constant.selectedZone = zone;
      Constant.isZoneAvailable = inside;
      if (inside) break;
    }
  }

  @override
  void onClose() {
    _cartSubscription?.cancel();
    _restaurantSubscription?.cancel();
    super.onClose();
  }
}
