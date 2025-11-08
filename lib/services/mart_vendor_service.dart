import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/models/mart_vendor_model.dart';

class MartVendorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'vendors';

  // Get all mart vendors
  static Future<List<MartVendorModel>> getAllMartVendors() async {
    try {
      print('🔍 [MART_VENDOR_SERVICE] Querying ALL mart vendors');
      print('📊 [MART_VENDOR_SERVICE] Query: vType="mart" AND isOpen=true');
      
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('vType', isEqualTo: 'mart')
          .where('isOpen', isEqualTo: true)
          .get();

      final vendors = <MartVendorModel>[];
      
      for (var doc in querySnapshot.docs) {
        try {
          final data = {...doc.data(), 'id': doc.id};
          print('🔍 [MART_VENDOR_SERVICE] DEBUG: All mart vendors - Raw document data for ${doc.id}:');
          print('   zoneId: ${data['zoneId']}');
          print('   vType: ${data['vType']}');
          print('   isOpen: ${data['isOpen']}');
          print('   title: ${data['title']}');
          
          final vendor = MartVendorModel.fromJson(data);
          vendors.add(vendor);
        } catch (e) {
          print('❌ [MART_VENDOR_SERVICE] Error processing vendor document ${doc.id}: $e');
          print('   Raw data: ${doc.data()}');
          // Continue with next vendor
        }
      }
      
      print('📊 [MART_VENDOR_SERVICE] Found ${vendors.length} total mart vendors');
      return vendors;
    } catch (e) {
      print('❌ [MART_VENDOR_SERVICE] Error fetching all mart vendors: $e');
      return [];
    }
  }

  // Get mart vendor by ID
  static Future<MartVendorModel?> getMartVendorById(String vendorId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(vendorId)
          .get();

      if (doc.exists) {
        return MartVendorModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error fetching mart vendor by ID: $e');
      return null;
    }
  }

  // Get default mart vendor (first available)
  static Future<MartVendorModel?> getDefaultMartVendor() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('vType', isEqualTo: 'mart')
          .where('isOpen', isEqualTo: true)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return MartVendorModel.fromJson({...doc.data(), 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error fetching default mart vendor: $e');
      return null;
    }
  }

  // Get mart vendors by category
  static Future<List<MartVendorModel>> getMartVendorsByCategory(String categoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('vType', isEqualTo: 'mart')
          .where('categoryID', arrayContains: categoryId)
          .where('isOpen', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MartVendorModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching mart vendors by category: $e');
      return [];
    }
  }

  // Get mart vendors by zone
  static Future<List<MartVendorModel>> getMartVendorsByZone(String zoneId) async {
    try {
      print('🔍 [MART_VENDOR_SERVICE] Querying mart vendors for zone: $zoneId');
      print('📊 [MART_VENDOR_SERVICE] Query: vType="mart" (filtering by zone in memory, regardless of isOpen status)');
      final allMartVendors = await _firestore
          .collection(_collectionName)
          .where('vType', isEqualTo: 'mart')
          .get();
      print('📊 [MART_VENDOR_SERVICE] Found ${allMartVendors.docs.length} total mart vendors in database');
      
      // Filter by zone and isOpen in memory (more reliable than Firestore query)
      final filteredVendors = <MartVendorModel>[];
      
      for (var doc in allMartVendors.docs) {
        try {
          final data = doc.data();
          print('🔍 [MART_VENDOR_SERVICE] Processing vendor document: ${doc.id}');
          print('   Raw data keys: ${data.keys.toList()}');
          
          final vendor = MartVendorModel.fromJson({...data, 'id': doc.id});
          
          print('🔍 [MART_VENDOR_SERVICE] Checking vendor: ${vendor.title}');
          print('   Zone ID: ${vendor.zoneId} (target: $zoneId)');
          print('   Is Open: ${vendor.isOpen}');
          print('   vType: ${vendor.vType}');
          
          // Check if vendor matches our criteria (zone only, regardless of open/closed status)
          if (vendor.zoneId == zoneId) {
            print('✅ [MART_VENDOR_SERVICE] Vendor matches zone criteria - adding to results');
            print('   - Zone ID matches: ${vendor.zoneId}');
            print('   - Is Open: ${vendor.isOpen}');
            filteredVendors.add(vendor);
          } else {
            print('❌ [MART_VENDOR_SERVICE] Vendor does not match zone criteria');
            print('   - Zone ID mismatch: ${vendor.zoneId} != $zoneId');
          }
        } catch (e) {
          print('❌ [MART_VENDOR_SERVICE] Error processing vendor document ${doc.id}: $e');
          print('   Raw data: ${doc.data()}');
          // Continue with next vendor
        }
      }
      
      print('📊 [MART_VENDOR_SERVICE] Final filtered results: ${filteredVendors.length} vendors');
      
      // Return the filtered results
      return filteredVendors;
    } catch (e) {
      print('❌ [MART_VENDOR_SERVICE] Error fetching mart vendors by zone $zoneId: $e');
      return [];
    }
  }

  // Get nearby mart vendors (within radius)
  static Future<List<MartVendorModel>> getNearbyMartVendors(
    double latitude, 
    double longitude, 
    double radiusKm
  ) async {
    try {
      // Create a bounding box for the radius
      final latDelta = radiusKm / 111.0; // 1 degree = ~111 km
      final lonDelta = radiusKm / (111.0 * cos(latitude * pi / 180));

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('vType', isEqualTo: 'mart')
          .where('isOpen', isEqualTo: true)
          .where('latitude', isGreaterThanOrEqualTo: latitude - latDelta)
          .where('latitude', isLessThanOrEqualTo: latitude + latDelta)
          .where('longitude', isGreaterThanOrEqualTo: longitude - lonDelta)
          .where('longitude', isLessThanOrEqualTo: longitude + lonDelta)
          .get();

      final vendors = querySnapshot.docs
          .map((doc) => MartVendorModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Filter by actual distance and sort by proximity
      vendors.sort((a, b) {
        final distA = _calculateDistance(latitude, longitude, a.latitude ?? 0, a.longitude ?? 0);
        final distB = _calculateDistance(latitude, longitude, b.latitude ?? 0, b.longitude ?? 0);
        return distA.compareTo(distB);
      });

      return vendors.where((vendor) {
        final distance = _calculateDistance(
          latitude, 
          longitude, 
          vendor.latitude ?? 0, 
          vendor.longitude ?? 0
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      print('Error fetching nearby mart vendors: $e');
      return [];
    }
  }

  // Create a new mart vendor
  static Future<bool> createMartVendor(MartVendorModel vendor) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(vendor.id)
          .set(vendor.toJson());
      return true;
    } catch (e) {
      print('Error creating mart vendor: $e');
      return false;
    }
  }

  // Update mart vendor
  static Future<bool> updateMartVendor(String vendorId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(vendorId)
          .update(data);
      return true;
    } catch (e) {
      print('Error updating mart vendor: $e');
      return false;
    }
  }

  // Delete mart vendor
  static Future<bool> deleteMartVendor(String vendorId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(vendorId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting mart vendor: $e');
      return false;
    }
  }

  // Check if mart vendor is open
  static Future<bool> isMartVendorOpen(String vendorId) async {
    try {
      final vendor = await getMartVendorById(vendorId);
      return vendor?.isCurrentlyOpen ?? false;
    } catch (e) {
      print('Error checking if mart vendor is open: $e');
      return false;
    }
  }

  // Get mart vendor working hours
  static Future<List<MartWorkingHours>?> getMartVendorWorkingHours(String vendorId) async {
    try {
      final vendor = await getMartVendorById(vendorId);
      return vendor?.workingHours;
    } catch (e) {
      print('Error fetching mart vendor working hours: $e');
      return null;
    }
  }

  // Helper method to calculate distance between two points
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
