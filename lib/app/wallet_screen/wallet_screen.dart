import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/order_list_screen/order_details_screen.dart';
import 'package:customer/app/wallet_screen/payment_list_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/controllers/wallet_controller.dart';
import 'package:customer/models/wallet_transaction_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:customer/widget/translated_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: WalletController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            body: controller.isLoading.value
                ? Constant.loader()
                : Constant.userModel == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/login.gif",
                              height: 120,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            TranslatedText(
                              "Please Log In to Continue",
                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 22, fontFamily: AppThemeData.semiBold),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            TranslatedText(
                              "You’re not logged in. Please sign in to access your account and explore all features.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.bold),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            RoundedButtonFill(
                              title: "Log in",
                              width: 55,
                              height: 5.5,
                              color: AppThemeData.primary300,
                              textColor: AppThemeData.grey50,
                              onPress: () async {
                                Get.offAll(const LoginScreen());
                              },
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TranslatedText(
                                              "My Wallet",
                                              style: TextStyle(
                                                fontSize: 24,
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontFamily: AppThemeData.semiBold,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            TranslatedText(
                                              "Keep track of your balance, transactions, and payment methods all in one place.",
                                              style: TextStyle(
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontFamily: AppThemeData.regular,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: AppThemeData.primaryGradient,
                                      borderRadius: BorderRadius.circular(AppThemeData.radiusXl),
                                      boxShadow: themeChange.getThem() ? null : AppThemeData.primaryGlow,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppThemeData.radiusXl),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: -46,
                                            right: -34,
                                            child: Container(
                                              width: 140,
                                              height: 140,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withValues(alpha: 0.10),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: -54,
                                            left: -38,
                                            child: Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withValues(alpha: 0.08),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                            child: Column(
                                              children: [
                                                TranslatedText(
                                                  "My Wallet",
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    color: AppThemeData.primary50,
                                                    fontSize: 16,
                                                    overflow: TextOverflow.ellipsis,
                                                    fontFamily: AppThemeData.regular,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                                Text(
                                                  Constant.amountShow(amount: controller.userModel.value.walletAmount.toString()),
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey50,
                                                    fontSize: 32,
                                                    overflow: TextOverflow.ellipsis,
                                                    fontFamily: AppThemeData.extraBold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 80),
                                                  child: frostedHeroButton(
                                                    title: "Top up",
                                                    onPress: () {
                                                      Get.to(const PaymentListScreen());
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: controller.walletTransactionList.isEmpty
                                  ? emptyTransactionView(themeChange, "Transaction not found")
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TranslatedText(
                                            "Transaction History",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: AppThemeData.bold,
                                              fontWeight: FontWeight.w700,
                                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 12,
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                              padding: const EdgeInsets.only(bottom: 100),
                                              itemCount: controller.walletTransactionList.length,
                                              itemBuilder: (context, index) {
                                                WalletTransactionModel walletTractionModel = controller.walletTransactionList[index];
                                                return transactionCard(controller, themeChange, walletTractionModel);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
          );
        });
  }

  Widget frostedHeroButton({required String title, required VoidCallback onPress}) {
    return InkWell(
      onTap: onPress,
      borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(AppThemeData.radiusPill),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
        ),
        child: Center(
          child: TranslatedText(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: AppThemeData.semiBold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget emptyTransactionView(DarkThemeProvider themeChange, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppThemeData.primary50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 32,
              color: AppThemeData.primary300,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          TranslatedText(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontFamily: AppThemeData.medium,
              fontWeight: FontWeight.w500,
              color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
            ),
          ),
        ],
      ),
    );
  }

  Widget transactionCard(WalletController controller, themeChange, WalletTransactionModel transactionModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey50,
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        border: Border.all(color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100),
        boxShadow: themeChange.getThem() ? null : AppThemeData.cardShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppThemeData.radiusLg),
        onTap: () async {
          await FireStoreUtils.getOrderByOrderId(transactionModel.orderId.toString()).then(
            (value) {
              if (value != null) {
                Get.to(const OrderDetailsScreen(), arguments: {"orderModel": value});
              }
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: transactionModel.isTopup == true
                      ? AppThemeData.success50
                      : AppThemeData.danger50,
                  borderRadius: BorderRadius.circular(AppThemeData.radiusMd),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: transactionModel.isTopup == false
                      ? SvgPicture.asset(
                          "assets/icons/ic_debit.svg",
                          height: 16,
                          width: 16,
                        )
                      : SvgPicture.asset(
                          "assets/icons/ic_credit.svg",
                          height: 16,
                          width: 16,
                        ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TranslatedText(
                            transactionModel.note.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w600,
                              color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                            ),
                          ),
                        ),
                        Text(
                          Constant.amountShow(amount: transactionModel.amount.toString()),
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppThemeData.bold,
                            fontWeight: FontWeight.w700,
                            color: transactionModel.isTopup == true ? AppThemeData.success400 : AppThemeData.danger300,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    TranslatedText(
                      Constant.timestampToDateTime(transactionModel.date!),
                      style: TextStyle(fontSize: 12, fontFamily: AppThemeData.medium, fontWeight: FontWeight.w500, color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum PaymentGateway {
  payFast,
  mercadoPago,
  paypal,
  stripe,
  flutterWave,
  payStack,
  paytm,
  razorpay,
  cod,
  wallet,
  midTrans,
  orangeMoney,
  xendit,
  mtnMomo,
  phonePe,
  instamojo,
  foloosi,
  payMongo,
  cashfree
}
