import 'package:customer/constant/constant.dart';
import 'package:customer/services/mart_vendor_service.dart';
import 'package:customer/models/mart_vendor_model.dart';
import 'package:customer/models/zone_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:geolocator/geolocator.dart';

class MartZoneUtils {
  static List<MartVendorModel>? _cachedMartVendors;
  static DateTime? _lastFetchTime;

  static Future<List<MartVendorModel>> getCachedMartVendors() async {
    // If cached within last 3 minutes, return cache
    if (_cachedMartVendors != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 3) {
      return _cachedMartVendors!;
    }

    final zoneId = Constant.selectedZone?.id;
    if (zoneId == null) return [];

    final vendors = await MartVendorService.getMartVendorsByZone(zoneId);

    _cachedMartVendors = vendors;
    _lastFetchTime = DateTime.now();
    return vendors;
  }
  /// Check if mart is available in the current zone
  /// Returns true if there's at least one mart vendor in the current zone
  static Future<bool> isMartAvailableInCurrentZone() async {
    try {
      print('\n🔍 [MART_ZONE_UTILS] ===== MART ZONE CHECKING STARTED =====');
      print('📍 [MART_ZONE_UTILS] Current Zone ID: ${Constant.selectedZone?.id ?? "NULL"}');
      print('📍 [MART_ZONE_UTILS] Current Zone Name: ${Constant.selectedZone?.name ?? "NULL"}');
      print('📍 [MART_ZONE_UTILS] Zone Latitude: ${Constant.selectedZone?.latitude ?? "NULL"}');
      print('📍 [MART_ZONE_UTILS] Zone Longitude: ${Constant.selectedZone?.longitude ?? "NULL"}');
      print('📍 [MART_ZONE_UTILS] Zone Published: ${Constant.selectedZone?.publish ?? "NULL"}');
      
      // Check if we have a selected zone
      if (Constant.selectedZone?.id == null) {
        print('❌ [MART_ZONE_UTILS] No zone selected - Mart not available');
        print('🔍 [MART_ZONE_UTILS] ===== MART ZONE CHECKING ENDED =====\n');
        return false;
      }

      print('🔍 [MART_ZONE_UTILS] Fetching mart vendors for zone: ${Constant.selectedZone!.id}');
      print('🔍 [MART_ZONE_UTILS] DEBUG: Current zone ID type: ${Constant.selectedZone!.id.runtimeType}');
      print('🔍 [MART_ZONE_UTILS] DEBUG: Current zone ID length: ${Constant.selectedZone!.id!.length}');
      print('🔍 [MART_ZONE_UTILS] DEBUG: Current zone ID bytes: ${Constant.selectedZone!.id!.codeUnits}');
      
      // DEBUG: Let's also check all mart vendors to see what zones they're in
      print('🔍 [MART_ZONE_UTILS] DEBUG: Checking all mart vendors in database...');
      final allMartVendors = await MartVendorService.getAllMartVendors();
      print('📊 [MART_ZONE_UTILS] DEBUG: Total mart vendors in database: ${allMartVendors.length}');
      
      if (allMartVendors.isNotEmpty) {
        print('📊 [MART_ZONE_UTILS] DEBUG: All mart vendors and their zones:');
        for (int i = 0; i < allMartVendors.length; i++) {
          final vendor = allMartVendors[i];
          print('   ${i + 1}. ${vendor.title} (ID: ${vendor.id})');
          print('      Zone ID: ${vendor.zoneId}');
          print('      Zone ID type: ${vendor.zoneId.runtimeType}');
          print('      Zone ID length: ${vendor.zoneId?.length}');
          print('      Zone ID bytes: ${vendor.zoneId?.codeUnits}');
          print('      vType: ${vendor.vType}');
          print('      Is Open: ${vendor.isOpen}');
          print('      Location: ${vendor.latitude}, ${vendor.longitude}');
          
          // Check if zone IDs match
          final currentZoneId = Constant.selectedZone!.id!;
          final vendorZoneId = vendor.zoneId;
          print('      Zone ID Match: ${currentZoneId == vendorZoneId}');
          print('      Zone ID Equals: ${currentZoneId == vendorZoneId}');
          print('      Zone ID Contains: ${currentZoneId.contains(vendorZoneId ?? '')}');
        }
      }
      
      // Get mart vendors for the current zone
      final martVendors = await MartVendorService.getMartVendorsByZone(Constant.selectedZone!.id!);
      
      // Check if there are any mart vendors in this zone
      final isAvailable = martVendors.isNotEmpty;
      
      print('📊 [MART_ZONE_UTILS] Mart vendors found: ${martVendors.length}');
      
      if (martVendors.isNotEmpty) {
        print('✅ [MART_ZONE_UTILS] Mart vendors in zone:');
        for (int i = 0; i < martVendors.length; i++) {
          final vendor = martVendors[i];
          print('   ${i + 1}. Vendor ID: ${vendor.id}');
          print('      Name: ${vendor.title}');
          print('      vType: ${vendor.vType}');
          print('      Zone ID: ${vendor.zoneId}');
          print('      Is Open: ${vendor.isOpen}');
          print('      Location: ${vendor.latitude}, ${vendor.longitude}');
        }
      } else {
        print('❌ [MART_ZONE_UTILS] No mart vendors found in this zone');
      }
      
      print('🎯 [MART_ZONE_UTILS] Final Result: Mart Available = $isAvailable');
      print('🔍 [MART_ZONE_UTILS] ===== MART ZONE CHECKING ENDED =====\n');
      
      return isAvailable;
    } catch (e) {
      print('❌ [MART_ZONE_UTILS] Error checking mart availability: $e');
      print('🔍 [MART_ZONE_UTILS] ===== MART ZONE CHECKING ENDED (ERROR) =====\n');
      return false;
    }
  }

  /// Check if mart is temporarily closed in the current zone
  /// Returns true if there are mart vendors but all are closed
  static Future<bool> isMartTemporarilyClosedInCurrentZone() async {
    try {
      print('\n🔍 [MART_ZONE_UTILS] ===== MART TEMPORARILY CLOSED CHECK STARTED =====');
      print('📍 [MART_ZONE_UTILS] Current Zone ID: ${Constant.selectedZone?.id ?? "NULL"}');

      if (Constant.selectedZone?.id == null) {
        print('❌ [MART_ZONE_UTILS] No zone selected - Cannot check mart status');
        return false;
      }
      final martVendors = await MartVendorService.getMartVendorsByZone(Constant.selectedZone!.id!);
      if (martVendors.isEmpty) {
        print('📊 [MART_ZONE_UTILS] No mart vendors in zone - Not temporarily closed');
        return false;
      }

      final allClosed = martVendors.every((vendor) => vendor.isOpen == false);
      print('📊 [MART_ZONE_UTILS] Mart vendors in zone: ${martVendors.length}');
      print('📊 [MART_ZONE_UTILS] All vendors closed: $allClosed');
      
      if (martVendors.isNotEmpty) {
        print('📊 [MART_ZONE_UTILS] Vendor status check:');
        for (int i = 0; i < martVendors.length; i++) {
          final vendor = martVendors[i];
          print('   ${i + 1}. ${vendor.title} - Is Open: ${vendor.isOpen}');
        }
      }
      
      print('🎯 [MART_ZONE_UTILS] Final Result: Mart Temporarily Closed = $allClosed');
      print('🔍 [MART_ZONE_UTILS] ===== MART TEMPORARILY CLOSED CHECK ENDED =====\n');
      
      return allClosed;
    } catch (e) {
      print('❌ [MART_ZONE_UTILS] Error checking mart temporarily closed status: $e');
      return false;
    }
  }

  /// Get mart vendors for the current zone
  static Future<List<MartVendorModel>> getMartVendorsForCurrentZone() async {
    try {
      print('🔍 [MART_ZONE_UTILS] Getting mart vendors for current zone');
      print('📍 [MART_ZONE_UTILS] Current Zone ID: ${Constant.selectedZone?.id ?? "NULL"}');
      
      if (Constant.selectedZone?.id == null) {
        print('❌ [MART_ZONE_UTILS] No zone selected - returning empty list');
        return [];
      }

      final vendors = await MartVendorService.getMartVendorsByZone(Constant.selectedZone!.id!);
      print('📊 [MART_ZONE_UTILS] Retrieved ${vendors.length} mart vendors for zone ${Constant.selectedZone!.id}');
      return vendors;
    } catch (e) {
      print('❌ [MART_ZONE_UTILS] Error getting mart vendors for current zone: $e');
      return [];
    }
  }

  /// Check if a specific zone has mart vendors
  static Future<bool> isMartAvailableInZone(String zoneId) async {
    try {
      print('🔍 [MART_ZONE_UTILS] Checking mart availability for specific zone: $zoneId');
      final martVendors = await MartVendorService.getMartVendorsByZone(zoneId);
      final isAvailable = martVendors.isNotEmpty;
      print('📊 [MART_ZONE_UTILS] Zone $zoneId has ${martVendors.length} mart vendors - Available: $isAvailable');
      return isAvailable;
    } catch (e) {
      print('❌ [MART_ZONE_UTILS] Error checking mart availability for zone $zoneId: $e');
      return false;
    }
  }

  /// Get all zones that have mart vendors
  static Future<List<String>> getZonesWithMartVendors() async {
    try {
      print('🔍 [MART_ZONE_UTILS] Getting all zones with mart vendors');
      final allMartVendors = await MartVendorService.getAllMartVendors();
      final zonesWithMart = allMartVendors
          .where((vendor) => vendor.zoneId != null)
          .map((vendor) => vendor.zoneId!)
          .toSet()
          .toList();
      
      print('📊 [MART_ZONE_UTILS] Total mart vendors found: ${allMartVendors.length}');
      print('📍 [MART_ZONE_UTILS] Zones with mart vendors: $zonesWithMart');
      return zonesWithMart;
    } catch (e) {
      print('❌ [MART_ZONE_UTILS] Error getting zones with mart vendors: $e');
      return [];
    }
  }

  /// Get zone ID for specific coordinates
  /// This is the core method for zone detection during address saving
  static Future<String> getZoneIdForCoordinates(double latitude, double longitude) async {
    try {
      print('🔍 [MART_ZONE_UTILS] ===== ZONE DETECTION STARTED =====');
      print('📍 [MART_ZONE_UTILS] Coordinates: lat=$latitude, lng=$longitude');
      
      // Get all zones from Firestore
      final zones = await FireStoreUtils.getZone();
      
      if (zones == null || zones.isEmpty) {
        print('❌ [MART_ZONE_UTILS] No zones found in database');
        print('🔍 [MART_ZONE_UTILS] ===== ZONE DETECTION ENDED (NO ZONES) =====');
        return '';
      }
      
      print('📊 [MART_ZONE_UTILS] Found ${zones.length} zones in database');
      
      // Check each zone to see if coordinates fall within it
      for (int i = 0; i < zones.length; i++) {
        final zone = zones[i];
        print('🔍 [MART_ZONE_UTILS] Checking zone ${i + 1}: ${zone.name} (ID: ${zone.id})');
        print('   📍 Zone center: lat=${zone.latitude}, lng=${zone.longitude}');
        print('   📍 Zone area points: ${zone.area?.length ?? 0}');
        print('   📍 Zone published: ${zone.publish}');
        
        // Skip unpublished zones
        if (zone.publish != true) {
          print('   ⏭️ Skipping unpublished zone');
          continue;
        }
        
        // Check if coordinates fall within this zone
        if (await _isCoordinateInZone(latitude, longitude, zone)) {
          print('✅ [MART_ZONE_UTILS] Coordinates found in zone: ${zone.name} (${zone.id})');
          print('🔍 [MART_ZONE_UTILS] ===== ZONE DETECTION ENDED (SUCCESS) =====');
          return zone.id ?? '';
        } else {
          print('   ❌ Coordinates not in this zone');
        }
      }
      
      print('❌ [MART_ZONE_UTILS] Coordinates not found in any zone');
      print('🔍 [MART_ZONE_UTILS] ===== ZONE DETECTION ENDED (NO MATCH) =====');
      return '';
    } catch (e) {
      print('❌ [MART_ZONE_UTILS] Error detecting zone for coordinates: $e');
      print('🔍 [MART_ZONE_UTILS] ===== ZONE DETECTION ENDED (ERROR) =====');
      return '';
    }
  }

  /// Check if coordinates are within a zone (polygon or circle)
  static Future<bool> _isCoordinateInZone(double lat, double lng, ZoneModel zone) async {
    try {
      // If zone has center coordinates, try both polygon and circular detection
      if (zone.latitude != null && zone.longitude != null) {
        
        // First try polygon detection if area points exist
        if (zone.area != null && zone.area!.isNotEmpty) {
          final isInPolygon = _isPointInPolygon(lat, lng, zone.area!);
          print('   🔍 Polygon check: points=${zone.area!.length}, inPolygon=$isInPolygon');
          
          // If polygon detection succeeds, return true
          if (isInPolygon) {
            return true;
          }
        }
        
        // If polygon detection fails or no area points, try circular detection
        final distance = Geolocator.distanceBetween(
          zone.latitude!,
          zone.longitude!,
          lat,
          lng,
        );
        
        // Use larger radius for better coverage (15km for all zones)
        const defaultRadius = 15000; // 15km in meters
        final isInCircle = distance <= defaultRadius;
        
        print('   🔍 Circle check: distance=${distance}m, radius=${defaultRadius}m, inCircle=$isInCircle');
        return isInCircle;
      }
      
      print('   ❌ Zone has no center coordinates');
      return false;
    } catch (e) {
      print('   ❌ Error checking coordinate in zone: $e');
      return false;
    }
  }

  /// Check if point is inside polygon using ray casting algorithm
  static bool _isPointInPolygon(double lat, double lng, List<dynamic> polygon) {
    try {
      if (polygon.length < 3) {
        print('   ❌ Polygon has less than 3 points');
        return false;
      }
      
      int intersections = 0;
      int n = polygon.length;
      
      for (int i = 0; i < n; i++) {
        // Get current and next point
        final current = polygon[i];
        final next = polygon[(i + 1) % n];
        
        // Extract coordinates - handle both GeoPoint objects and Map objects
        double p1Lat, p1Lng, p2Lat, p2Lng;
        
        // Handle GeoPoint objects (from Firestore)
        if (current.runtimeType.toString().contains('GeoPoint')) {
          p1Lat = current.latitude;
          p1Lng = current.longitude;
        } else if (current is Map && current.containsKey('latitude') && current.containsKey('longitude')) {
          // Handle Map objects with latitude/longitude keys
          p1Lat = (current['latitude'] as num).toDouble();
          p1Lng = (current['longitude'] as num).toDouble();
        } else if (current is Map && current.containsKey('lat') && current.containsKey('lng')) {
          // Handle Map objects with lat/lng keys
          p1Lat = (current['lat'] as num).toDouble();
          p1Lng = (current['lng'] as num).toDouble();
        } else {
          print('   ❌ Unsupported polygon point format: ${current.runtimeType}');
          continue;
        }
        
        // Handle next point
        if (next.runtimeType.toString().contains('GeoPoint')) {
          p2Lat = next.latitude;
          p2Lng = next.longitude;
        } else if (next is Map && next.containsKey('latitude') && next.containsKey('longitude')) {
          p2Lat = (next['latitude'] as num).toDouble();
          p2Lng = (next['longitude'] as num).toDouble();
        } else if (next is Map && next.containsKey('lat') && next.containsKey('lng')) {
          p2Lat = (next['lat'] as num).toDouble();
          p2Lng = (next['lng'] as num).toDouble();
        } else {
          print('   ❌ Unsupported polygon point format: ${next.runtimeType}');
          continue;
        }
        
        // Ray casting algorithm
        if (((p1Lat > lng) != (p2Lat > lng)) &&
            (lat < (p2Lng - p1Lng) * (lng - p1Lat) / (p2Lat - p1Lat) + p1Lng)) {
          intersections++;
        }
      }
      
      final isInside = (intersections % 2) == 1;
      print('   🔍 Ray casting: intersections=$intersections, isInside=$isInside');
      return isInside;
    } catch (e) {
      print('   ❌ Error in polygon point check: $e');
      return false;
    }
  }
}
