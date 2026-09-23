import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
// Prefixed: map_launcher 6.x also exports a `Location` type, which clashes
// with the `location` package's Location used above.
import 'package:map_launcher/map_launcher.dart' as map_launcher;

class Utils {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Location().requestService();
      return null;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  /// Opens driving directions in the map app configured by the admin
  /// (`Constant.mapType`). Uses map_launcher 6.x's request-builder API
  /// (MapApp/TravelMode replaced the old MapType/DirectionsMode).
  static redirectMap({required String name, required double latitude, required double longLatitude}) async {
    const Map<String, (map_launcher.MapApp, String)> supported = {
      "google": (map_launcher.MapApp.google, "Google map"),
      "googleGo": (map_launcher.MapApp.googleGo, "Google Go map"),
      "waze": (map_launcher.MapApp.waze, "Waze"),
      "mapswithme": (map_launcher.MapApp.mapswithme, "Mapswithme"),
      "yandexNavi": (map_launcher.MapApp.yandexNavi, "YandexNavi"),
      "yandexMaps": (map_launcher.MapApp.yandexMaps, "yandexMaps map"),
    };

    final entry = supported[Constant.mapType];
    if (entry == null) return;
    final (mapApp, label) = entry;

    final request = map_launcher.MapLauncher.directions(
      map_launcher.Location.coords(latitude, longLatitude, title: name),
      mode: map_launcher.TravelMode.driving,
    );

    final available = await request.getSupportedMaps([mapApp]);
    if (available.isEmpty) {
      ShowToastDialog.showToast("$label is not installed");
      return;
    }
    await request.show(map: mapApp);
  }
}
