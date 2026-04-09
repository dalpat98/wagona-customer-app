import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ShowToastDialog {
  static void showToast(String? message, {EasyLoadingToastPosition position = EasyLoadingToastPosition.top}) {
    EasyLoading.showToast(message!.tr, toastPosition: position);
  }

  static void showLoader(String message) {
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;

    EasyLoading.show(
      status: message,
      maskType: EasyLoadingMaskType.black,
    );
  }

  static void closeLoader() {
    EasyLoading.dismiss();
  }
}
