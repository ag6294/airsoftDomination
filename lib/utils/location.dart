import 'package:location/location.dart';

class LocationUtils {
 static Future<LocationData> getCurrentUserLocation() async {
    return await Location().getLocation();
  }

}