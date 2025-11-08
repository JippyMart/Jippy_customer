import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/models/mart_banner_model.dart';
import 'package:customer/models/mart_category_model.dart';
import 'package:customer/models/mart_item_model.dart';
import 'package:customer/models/mart_subcategory_model.dart';
import 'package:customer/models/mart_vendor_model.dart';
import 'package:get/get.dart';

class MartFirestoreService extends GetxService {
  // Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection name
  static const String _collectionName = 'mart_items';

  // Initialize the service
  Future<MartFirestoreService> init() async {
    print('[MART FIRESTORE] 🚀 Initializing MartFirestoreService...');
    print('[MART FIRESTORE] 🔥 Firestore instance: ${_firestore.app.name}');
    print('[MART FIRESTORE] ✅ MartFirestoreService initialized successfully');
    return this;
  }

  /// Get trending items from Firestore
  Future<List<MartItemModel>> getTrendingItems({int limit = 20}) async {
    try {
      print('[MART FIRESTORE] 🔥 Fetching trending items from Firestore...');

      // Query Firestore for trending items
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isTrending', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .where('publish', isEqualTo: true)
          .limit(limit)
          .get();

      print(
          '[MART FIRESTORE] 🔥 Firestore query completed, found ${querySnapshot.docs.length} trending items');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No trending items found in Firestore');
        return [];
      }

      // Convert Firestore documents to MartItemModel
      final items = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data == null) return null;

              // Ensure data is a Map<String, dynamic>
              if (data is! Map<String, dynamic>) {
                print(
                    '[MART FIRESTORE] ⚠️ Document data is not a Map for ${doc.id}, type: ${data.runtimeType}');
                return null;
              }

              final Map<String, dynamic> itemData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              itemData['id'] = doc.id;

              // Handle array fields that might be null
              if (itemData['addOnsPrice'] == null) itemData['addOnsPrice'] = [];
              if (itemData['addOnsTitle'] == null) itemData['addOnsTitle'] = [];
              if (itemData['options'] == null) itemData['options'] = [];
              if (itemData['photos'] == null) itemData['photos'] = [];
              if (itemData['subcategoryID'] == null)
                itemData['subcategoryID'] = [];
              if (itemData['product_specification'] == null)
                itemData['product_specification'] = {};

              // Handle numeric fields that might be strings
              if (itemData['reviewCount'] is String) {
                itemData['reviewCount'] =
                    int.tryParse(itemData['reviewCount']) ?? 0;
              }
              if (itemData['reviewSum'] is String) {
                itemData['reviewSum'] =
                    double.tryParse(itemData['reviewSum']) ?? 0.0;
              }

              return MartItemModel.fromJson(itemData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore document ${doc.id}: $e');
              print('[MART FIRESTORE] Document data: ${doc.data()}');
              return null;
            }
          })
          .whereType<MartItemModel>()
          .toList();

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${items.length} trending items from Firestore');

      // Debug: Log the trending items
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        print(
            '[MART FIRESTORE]   ${i + 1}. ${item.name} - isTrending: ${item.isTrending}, price: ₹${item.price}');
      }

      return items;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching trending items from Firestore: $e');
      return [];
    }
  }

  /// Get featured items from Firestore
  Future<List<MartItemModel>> getFeaturedItems({int limit = 20}) async {
    try {
      print('[MART FIRESTORE] ⭐ Fetching featured items from Firestore...');

      // Query Firestore for featured items
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isFeature', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .where('publish', isEqualTo: true)
          .limit(limit)
          .get();

      print(
          '[MART FIRESTORE] ⭐ Firestore query completed, found ${querySnapshot.docs.length} featured items');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No featured items found in Firestore');
        return [];
      }

      // Convert Firestore documents to MartItemModel
      final items = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data == null) return null;

              // Ensure data is a Map<String, dynamic>
              if (data is! Map<String, dynamic>) {
                print(
                    '[MART FIRESTORE] ⚠️ Document data is not a Map for ${doc.id}, type: ${data.runtimeType}');
                return null;
              }

              final Map<String, dynamic> itemData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              itemData['id'] = doc.id;

              // Handle array fields that might be null
              if (itemData['addOnsPrice'] == null) itemData['addOnsPrice'] = [];
              if (itemData['addOnsTitle'] == null) itemData['addOnsTitle'] = [];
              if (itemData['options'] == null) itemData['options'] = [];
              if (itemData['photos'] == null) itemData['photos'] = [];
              if (itemData['subcategoryID'] == null)
                itemData['subcategoryID'] = [];
              if (itemData['product_specification'] == null)
                itemData['product_specification'] = {};

              // Handle numeric fields that might be strings
              if (itemData['reviewCount'] is String) {
                itemData['reviewCount'] =
                    int.tryParse(itemData['reviewCount']) ?? 0;
              }
              if (itemData['reviewSum'] is String) {
                itemData['reviewSum'] =
                    double.tryParse(itemData['reviewSum']) ?? 0.0;
              }

              return MartItemModel.fromJson(itemData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore document ${doc.id}: $e');
              print('[MART FIRESTORE] Document data: ${doc.data()}');
              return null;
            }
          })
          .whereType<MartItemModel>()
          .toList();

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${items.length} featured items from Firestore');

      // Debug: Log the featured items
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        print(
            '[MART FIRESTORE]   ${i + 1}. ${item.name} - isFeature: ${item.isFeature}, price: ₹${item.price}');
      }

      return items;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching featured items from Firestore: $e');
      return [];
    }
  }

  /// Get items on sale from Firestore
  Future<List<MartItemModel>> getItemsOnSale({int limit = 20}) async {
    try {
      print('[MART FIRESTORE] 🏷️ Fetching items on sale from Firestore...');

      // Query Firestore for items on sale (where disPrice < price)
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isAvailable', isEqualTo: true)
          .where('publish', isEqualTo: true)
          .limit(limit)
          .get();

      print(
          '[MART FIRESTORE] 🏷️ Firestore query completed, found ${querySnapshot.docs.length} items');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No items found in Firestore');
        return [];
      }

      // Filter items on sale and convert to MartItemModel
      final items = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              // Add document ID to the data
              data['id'] = doc.id;

              // Handle array fields that might be null
              if (data['addOnsPrice'] == null) data['addOnsPrice'] = [];
              if (data['addOnsTitle'] == null) data['addOnsTitle'] = [];
              if (data['options'] == null) data['options'] = [];
              if (data['photos'] == null) data['photos'] = [];
              if (data['subcategoryID'] == null) data['subcategoryID'] = [];
              if (data['product_specification'] == null)
                data['product_specification'] = {};

              // Handle numeric fields that might be strings
              if (data['reviewCount'] is String) {
                data['reviewCount'] = int.tryParse(data['reviewCount']) ?? 0;
              }
              if (data['reviewSum'] is String) {
                data['reviewSum'] = double.tryParse(data['reviewSum']) ?? 0.0;
              }

              return MartItemModel.fromJson(data);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartItemModel>()
          .toList();

      // Filter for items on sale (where disPrice < price)
      final saleItems = items
          .where((item) => item.disPrice != null && item.disPrice! < item.price)
          .toList();

      print(
          '[MART FIRESTORE] ✅ Successfully found ${saleItems.length} items on sale');

      // Debug: Log the sale items
      for (int i = 0; i < saleItems.length; i++) {
        final item = saleItems[i];
        print(
            '[MART FIRESTORE]   ${i + 1}. ${item.name} - Original: ₹${item.price}, Sale: ₹${item.disPrice}');
      }

      return saleItems;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching items on sale from Firestore: $e');
      return [];
    }
  }

  /// Search items by name or description
  Future<List<MartItemModel>> searchItems({
    required String searchQuery,
    int limit = 20,
  }) async {
    try {
      print('[MART FIRESTORE] 🔍 Searching for items: "$searchQuery"');

      // Convert search query to lowercase for case-insensitive search
      final query = searchQuery.toLowerCase();

      // Query Firestore for items
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('isAvailable', isEqualTo: true)
          .where('publish', isEqualTo: true)
          .limit(limit)
          .get();

      print(
          '[MART FIRESTORE] 🔍 Firestore query completed, found ${querySnapshot.docs.length} items');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No items found in Firestore');
        return [];
      }

      // Filter items by search query and convert to MartItemModel
      final items = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              // Add document ID to the data
              data['id'] = doc.id;

              // Handle array fields that might be null
              if (data['addOnsPrice'] == null) data['addOnsPrice'] = [];
              if (data['addOnsTitle'] == null) data['addOnsTitle'] = [];
              if (data['options'] == null) data['options'] = [];
              if (data['photos'] == null) data['photos'] = [];
              if (data['subcategoryID'] == null) data['subcategoryID'] = [];
              if (data['product_specification'] == null)
                data['product_specification'] = {};

              // Handle numeric fields that might be strings
              if (data['reviewCount'] is String) {
                data['reviewCount'] = int.tryParse(data['reviewCount']) ?? 0;
              }
              if (data['reviewSum'] is String) {
                data['reviewSum'] = double.tryParse(data['reviewSum']) ?? 0.0;
              }

              return MartItemModel.fromJson(data);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartItemModel>()
          .toList();

      // Filter by search query (name or description)
      final searchResults = items.where((item) {
        final name = item.name.toLowerCase();
        final description = item.description.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();

      print(
          '[MART FIRESTORE] ✅ Search completed, found ${searchResults.length} matching items');

      // Debug: Log the search results
      for (int i = 0; i < searchResults.length; i++) {
        final item = searchResults[i];
        final shortDescription = item.description.length > 50
            ? '${item.description.substring(0, 50)}...'
            : item.description;
        print('[MART FIRESTORE]   ${i + 1}. ${item.name} - $shortDescription');
      }

      return searchResults;
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error searching items: $e');
      return [];
    }
  }

  // ==================== CATEGORIES METHODS ====================

  /// Get all categories from Firestore
  Future<List<MartCategoryModel>> getCategories({int limit = 100}) async {
    try {
      print('[MART FIRESTORE] 📂 Fetching categories from Firestore...');
      // Query Firestore for categories - simplified to avoid index issues
      final querySnapshot = await _firestore
          .collection('mart_categories')
          .where('publish', isEqualTo: true)
          .limit(limit)
          .get();

      print(
          '[MART FIRESTORE] 📂 Firestore query completed, found ${querySnapshot.docs.length} categories');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No categories found in Firestore');
        return [];
      }

      // Convert Firestore documents to MartCategoryModel
      final categories = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              // Add document ID to the data
              data['id'] = doc.id;

              // Handle array fields that might be null
              if (data['review_attributes'] == null)
                data['review_attributes'] = [];

              // Handle numeric fields that might be strings
              if (data['category_order'] is String) {
                data['category_order'] =
                    int.tryParse(data['category_order']) ?? 0;
              }
              if (data['section_order'] is String) {
                data['section_order'] =
                    int.tryParse(data['section_order']) ?? 0;
              }

              return MartCategoryModel.fromJson(data);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore category document ${doc.id}: $e');
              print('[MART FIRESTORE] Category data: ${doc.data()}');
              return null;
            }
          })
          .whereType<MartCategoryModel>()
          .toList();

      // Sort categories by category_order since we're not using orderBy
      categories.sort(
          (a, b) => (a.categoryOrder ?? 0).compareTo(b.categoryOrder ?? 0));

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${categories.length} categories from Firestore (client-side ordered)');

      // Debug: Log the categories
      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];
        final title = category.title ?? 'No Title';
        final order = category.categoryOrder ?? 0;
        final section = category.section ?? 'No Section';
        print(
            '[MART FIRESTORE]   ${i + 1}. $title - Order: $order, Section: $section');
      }

      return categories;
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error fetching categories from Firestore: $e');
      return [];
    }
  }

  /// Get homepage categories from Firestore
  Future<List<MartCategoryModel>> getHomepageCategories(
      {int limit = 10}) async {
    try {
      print(
          '[MART FIRESTORE] 🏠 Fetching homepage categories from Firestore...');
      print('[MART FIRESTORE] 🔍 Collection: mart_categories');
      print(
          '[MART FIRESTORE] 🔍 Query: publish=true, show_in_homepage=true, orderBy=category_order');
      print(
          '[MART FIRESTORE] ✅ Using composite index for optimal performance!');

      // Test Firestore connection
      print('[MART FIRESTORE] 🔍 Testing Firestore connection...');
      final testSnapshot =
          await _firestore.collection('mart_categories').limit(1).get();
      print(
          '[MART FIRESTORE] ✅ Firestore connection successful, found ${testSnapshot.docs.length} documents');

      // Query Firestore for homepage categories - simplified to avoid index issues
      print('[MART FIRESTORE] 🔍 Using simplified query: publish=true only');
      final querySnapshot = await _firestore
          .collection('mart_categories')
          .where('publish', isEqualTo: true)
          .limit(limit)
          .get();

      // Filter for homepage categories on the client side
      final homepageCategories = querySnapshot.docs.where((doc) {
        final data = doc.data();
        return data['show_in_homepage'] == true;
      }).toList();

      print(
          '[MART FIRESTORE] 🔍 Found ${querySnapshot.docs.length} total categories, ${homepageCategories.length} are homepage categories');

      if (homepageCategories.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No homepage categories found in Firestore');
        print('[MART FIRESTORE] 🔍 Available categories:');
        for (int i = 0; i < querySnapshot.docs.length && i < 5; i++) {
          final doc = querySnapshot.docs[i];
          final data = doc.data();
          print(
              '[MART FIRESTORE]   ${i + 1}. ${doc.id} - ${data['title']} - show_in_homepage: ${data['show_in_homepage']}');
        }

        // Fallback: Show first few categories even if they don't have show_in_homepage=true
        if (querySnapshot.docs.isNotEmpty) {
          print(
              '[MART FIRESTORE] 🔄 Fallback: Using first ${querySnapshot.docs.length} categories');
          final fallbackDocs = querySnapshot.docs.take(limit).toList();
          return fallbackDocs
              .map((doc) {
                try {
                  final data = doc.data();
                  final Map<String, dynamic> categoryData =
                      Map<String, dynamic>.from(data);
                  categoryData['id'] = doc.id;
                  if (categoryData['review_attributes'] == null)
                    categoryData['review_attributes'] = [];
                  if (categoryData['category_order'] is String) {
                    categoryData['category_order'] =
                        int.tryParse(categoryData['category_order']) ?? 0;
                  }
                  if (categoryData['section_order'] is String) {
                    categoryData['section_order'] =
                        int.tryParse(categoryData['section_order']) ?? 0;
                  }
                  return MartCategoryModel.fromJson(categoryData);
                } catch (e) {
                  print(
                      '[MART FIRESTORE] ❌ Error parsing fallback category ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<MartCategoryModel>()
              .toList();
        }

        return [];
      }

      // Use the filtered results
      final finalDocs = homepageCategories;

      print(
          '[MART FIRESTORE] 🏠 Firestore query completed, found ${finalDocs.length} homepage categories');

      // Convert Firestore documents to MartCategoryModel
      final categories = finalDocs
          .map((doc) {
            try {
              final data = doc.data();
              final Map<String, dynamic> categoryData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              categoryData['id'] = doc.id;

              // Handle array fields that might be null
              if (categoryData['review_attributes'] == null)
                categoryData['review_attributes'] = [];

              // Handle numeric fields that might be strings
              if (categoryData['category_order'] is String) {
                categoryData['category_order'] =
                    int.tryParse(categoryData['category_order']) ?? 0;
              }
              if (categoryData['section_order'] is String) {
                categoryData['section_order'] =
                    int.tryParse(categoryData['section_order']) ?? 0;
              }

              return MartCategoryModel.fromJson(categoryData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore homepage category document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartCategoryModel>()
          .toList();

      // Sort categories by category_order since we're not using orderBy
      categories.sort(
          (a, b) => (a.categoryOrder ?? 0).compareTo(b.categoryOrder ?? 0));

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${categories.length} homepage categories from Firestore (client-side ordered)');

      // Debug: Log the homepage categories
      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];
        final title = category.title ?? 'No Title';
        final order = category.categoryOrder ?? 0;
        final section = category.section ?? 'No Section';
        print(
            '[MART FIRESTORE]   ${i + 1}. $title - Order: $order, Section: $section');
      }

      return categories;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching homepage categories from Firestore: $e');
      print('[MART FIRESTORE] ❌ Error type: ${e.runtimeType}');
      print('[MART FIRESTORE] ❌ Error details: $e');
      return [];
    }
  }

  /// Get subcategories by parent category from Firestore
  Future<List<MartSubcategoryModel>> getSubcategoriesByParent({
    required String parentCategoryId,
    bool publish = true,
    String sortBy = 'subcategory_order',
    String sortOrder = 'asc',
    int limit = 100,
  }) async {
    try {
      print(
          '[MART FIRESTORE] 📋 Fetching subcategories for parent category: $parentCategoryId');

      // Query Firestore for subcategories
      final querySnapshot = await _firestore
          .collection('mart_subcategories')
          .where('parent_category_id', isEqualTo: parentCategoryId)
          .where('publish', isEqualTo: publish)
          .limit(limit)
          .get();

      print(
          '[MART FIRESTORE] 📋 Firestore query completed, found ${querySnapshot.docs.length} subcategories');

      if (querySnapshot.docs.isEmpty) {
        print(
            '[MART FIRESTORE] ⚠️ No subcategories found for parent category: $parentCategoryId');
        return [];
      }

      // Convert Firestore documents to MartSubcategoryModel
      final subcategories = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              final Map<String, dynamic> subcategoryData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              subcategoryData['id'] = doc.id;

              // Handle array fields that might be null
              if (subcategoryData['review_attributes'] == null)
                subcategoryData['review_attributes'] = [];

              // Handle numeric fields that might be strings
              if (subcategoryData['subcategory_order'] is String) {
                subcategoryData['subcategory_order'] =
                    int.tryParse(subcategoryData['subcategory_order']) ?? 0;
              }
              if (subcategoryData['category_order'] is String) {
                subcategoryData['category_order'] =
                    int.tryParse(subcategoryData['category_order']) ?? 0;
              }
              if (subcategoryData['section_order'] is String) {
                subcategoryData['section_order'] =
                    int.tryParse(subcategoryData['section_order']) ?? 0;
              }

              return MartSubcategoryModel.fromJson(subcategoryData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore subcategory document ${doc.id}: $e');
              print('[MART FIRESTORE] Subcategory data: ${doc.data()}');
              return null;
            }
          })
          .whereType<MartSubcategoryModel>()
          .toList();

      // Sort subcategories by subcategory_order since we're not using orderBy
      subcategories.sort((a, b) =>
          (a.subcategoryOrder ?? 0).compareTo(b.subcategoryOrder ?? 0));

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${subcategories.length} subcategories from Firestore (client-side ordered)');

      // Debug: Log the subcategories
      for (int i = 0; i < subcategories.length; i++) {
        final subcategory = subcategories[i];
        final title = subcategory.title ?? 'No Title';
        final order = subcategory.subcategoryOrder ?? 0;
        final parentId = subcategory.parentCategoryId ?? 'No Parent';
        print(
            '[MART FIRESTORE]   ${i + 1}. $title - Order: $order, Parent: $parentId');
      }

      return subcategories;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching subcategories from Firestore: $e');
      return [];
    }
  }

  /// Get all homepage subcategories directly from Firestore
  Future<List<MartSubcategoryModel>> getAllHomepageSubcategories() async {
    try {
      print(
          '[MART FIRESTORE] 🔥 Fetching all homepage subcategories directly from Firestore...');

      Query query = _firestore.collection('mart_subcategories');
      // First try with both filters and ordering
      try {
        query = query.where('show_in_homepage', isEqualTo: true);
        query = query.where('publish', isEqualTo: true);
        query = query.orderBy('subcategory_order', descending: false);

        final querySnapshot = await query.get();
        print(
            ' [MART FIRESTORE] 🔥 Found ${querySnapshot.docs.length} homepage subcategories in Firestore (with ordering)');

        // Log ALL documents found before parsing
        print('[MART FIRESTORE] 📋 ALL DOCUMENTS FOUND:');
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          final doc = querySnapshot.docs[i];
          final data = doc.data();
          print('[MART FIRESTORE] 📋 ${i + 1}. ID: ${doc.id}');
          print('[MART FIRESTORE] 📋    Data: $data');
          if (data is Map<String, dynamic>) {
            print(
                '[MART FIRESTORE] 📋    show_in_homepage: ${data['show_in_homepage']}');
            print('[MART FIRESTORE] 📋    publish: ${data['publish']}');
            print('[MART FIRESTORE] 📋    title: ${data['title']}');
            print(
                '[MART FIRESTORE] 📋    parent_category_id: ${data['parent_category_id']}');
          }
          print('[MART FIRESTORE] 📋    ---');
        }

        final subcategories = querySnapshot.docs
            .map((doc) {
              try {
                final data = doc.data();
                if (data == null) {
                  print('[MART FIRESTORE] ❌ Document ${doc.id} has null data');
                  return null;
                }

                // Ensure data is a Map<String, dynamic>
                if (data is! Map<String, dynamic>) {
                  print(
                      '[MART FIRESTORE] ⚠️ Document data is not a Map for ${doc.id}, type: ${data.runtimeType}');
                  return null;
                }

                final Map<String, dynamic> subcategoryData =
                    Map<String, dynamic>.from(data);

                // Add document ID to the data
                subcategoryData['id'] = doc.id;

                // Log the data being passed to fromJson
                print('[MART FIRESTORE] 🔍 Parsing document ${doc.id}:');
                print('[MART FIRESTORE] 🔍   Raw data: $subcategoryData');

                final subcategory =
                    MartSubcategoryModel.fromJson(subcategoryData);
                print(
                    '[MART FIRESTORE] ✅ Successfully parsed ${doc.id}: ${subcategory.title}');
                return subcategory;
              } catch (e) {
                print(
                    '[MART FIRESTORE] ❌ Error parsing subcategory document ${doc.id}: $e');
                print('[MART FIRESTORE] Document data: ${doc.data()}');
                return null;
              }
            })
            .whereType<MartSubcategoryModel>()
            .toList();

        // Sort subcategories by subcategory_order since we're not using orderBy
        subcategories.sort((a, b) =>
            (a.subcategoryOrder ?? 0).compareTo(b.subcategoryOrder ?? 0));

        print(
            '[MART FIRESTORE] ✅ Successfully parsed ${subcategories.length} homepage subcategories from Firestore');
        print('[MART FIRESTORE] 📊 PARSED SUBCATEGORIES:');

        // Debug: Log the homepage subcategories
        for (int i = 0; i < subcategories.length; i++) {
          final subcategory = subcategories[i];
          print(
              '[MART FIRESTORE]   ${i + 1}. ${subcategory.title} - Parent: ${subcategory.parentCategoryTitle} - Show in Homepage: ${subcategory.showInHomepage}');
        }

        return subcategories;
      } catch (e) {
        print(
            '[MART FIRESTORE] ⚠️ First query failed (likely index issue), trying without ordering: $e');

        // Fallback: try without ordering
        query = _firestore.collection('mart_subcategories');
        query = query.where('show_in_homepage', isEqualTo: true);
        query = query.where('publish', isEqualTo: true);

        final querySnapshot = await query.get();
        print(
            '[MART FIRESTORE] 🔥 Found ${querySnapshot.docs.length} homepage subcategories in Firestore (without ordering)');

        // Log ALL documents found before parsing (fallback)
        print('[MART FIRESTORE] 📋 ALL DOCUMENTS FOUND (FALLBACK):');
        for (int i = 0; i < querySnapshot.docs.length; i++) {
          final doc = querySnapshot.docs[i];
          final data = doc.data();
          print('[MART FIRESTORE] 📋 ${i + 1}. ID: ${doc.id}');
          print('[MART FIRESTORE] 📋    Data: $data');
          if (data is Map<String, dynamic>) {
            print(
                '[MART FIRESTORE] 📋    show_in_homepage: ${data['show_in_homepage']}');
            print('[MART FIRESTORE] 📋    publish: ${data['publish']}');
            print('[MART FIRESTORE] 📋    title: ${data['title']}');
            print(
                '[MART FIRESTORE] 📋    parent_category_id: ${data['parent_category_id']}');
          }
          print('[MART FIRESTORE] 📋    ---');
        }

        final subcategories = querySnapshot.docs
            .map((doc) {
              try {
                final data = doc.data();
                if (data == null) {
                  print(
                      '[MART FIRESTORE] ❌ Document ${doc.id} has null data (fallback)');
                  return null;
                }

                // Ensure data is a Map<String, dynamic>
                if (data is! Map<String, dynamic>) {
                  print(
                      '[MART FIRESTORE] ⚠️ Document data is not a Map for ${doc.id}, type: ${data.runtimeType} (fallback)');
                  return null;
                }

                final Map<String, dynamic> subcategoryData =
                    Map<String, dynamic>.from(data);

                // Add document ID to the data
                subcategoryData['id'] = doc.id;

                // Log the data being passed to fromJson (fallback)
                print(
                    '[MART FIRESTORE] 🔍 Parsing document ${doc.id} (fallback):');
                print('[MART FIRESTORE] 🔍   Raw data: $subcategoryData');

                final subcategory =
                    MartSubcategoryModel.fromJson(subcategoryData);
                print(
                    '[MART FIRESTORE] ✅ Successfully parsed ${doc.id}: ${subcategory.title} (fallback)');
                return subcategory;
              } catch (e) {
                print(
                    '[MART FIRESTORE] ❌ Error parsing subcategory document ${doc.id}: $e (fallback)');
                print('[MART FIRESTORE] Document data: ${doc.data()}');
                return null;
              }
            })
            .whereType<MartSubcategoryModel>()
            .toList();

        // Sort subcategories by subcategory_order since we're not using orderBy
        subcategories.sort((a, b) =>
            (a.subcategoryOrder ?? 0).compareTo(b.subcategoryOrder ?? 0));

        print(
            '[MART FIRESTORE] ✅ Successfully parsed ${subcategories.length} homepage subcategories from Firestore (fallback)');
        print('[MART FIRESTORE] 📊 PARSED SUBCATEGORIES (FALLBACK):');

        // Debug: Log the homepage subcategories
        for (int i = 0; i < subcategories.length; i++) {
          final subcategory = subcategories[i];
          print(
              '[MART FIRESTORE]   ${i + 1}. ${subcategory.title} - Parent: ${subcategory.parentCategoryTitle} - Show in Homepage: ${subcategory.showInHomepage}');
        }

        return subcategories;
      }
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching homepage subcategories from Firestore: $e');
      return [];
    }
  }

  /// Get ALL subcategories from Firestore (for debugging - no filters)
  Future<List<MartSubcategoryModel>> getAllSubcategoriesDebug() async {
    try {
      print(
          '[MART FIRESTORE] 🔍 DEBUG: Fetching ALL subcategories from Firestore (no filters)...');

      final querySnapshot =
          await _firestore.collection('mart_subcategories').get();
      print(
          '[MART FIRESTORE] 🔍 DEBUG: Found ${querySnapshot.docs.length} total subcategories in Firestore');

      // Log ALL documents found
      print('[MART FIRESTORE] 🔍 DEBUG: ALL DOCUMENTS IN COLLECTION:');
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        final doc = querySnapshot.docs[i];
        final data = doc.data();
        print('[MART FIRESTORE] 🔍 DEBUG: ${i + 1}. ID: ${doc.id}');
        print('[MART FIRESTORE] 🔍 DEBUG:    Data: $data');
        if (data is Map<String, dynamic>) {
          print(
              '[MART FIRESTORE] 🔍 DEBUG:    show_in_homepage: ${data['show_in_homepage']}');
          print('[MART FIRESTORE] 🔍 DEBUG:    publish: ${data['publish']}');
          print('[MART FIRESTORE] 🔍 DEBUG:    title: ${data['title']}');
          print(
              '[MART FIRESTORE] 🔍 DEBUG:    parent_category_id: ${data['parent_category_id']}');
        }
        print('[MART FIRESTORE] 🔍 DEBUG:    ---');
      }

      final subcategories = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data == null) {
                print('[MART FIRESTORE] ❌ Document ${doc.id} has null data');
                return null;
              }

              // Ensure data is a Map<String, dynamic>
              if (data is! Map<String, dynamic>) {
                print(
                    '[MART FIRESTORE] 🔍 DEBUG: Document data is not a Map for ${doc.id}, type: ${data.runtimeType}');
                return null;
              }

              final Map<String, dynamic> subcategoryData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              subcategoryData['id'] = doc.id;

              final subcategory =
                  MartSubcategoryModel.fromJson(subcategoryData);
              print(
                  '[MART FIRESTORE] 🔍 DEBUG: Successfully parsed ${doc.id}: ${subcategory.title}');
              return subcategory;
            } catch (e) {
              print(
                  '[MART FIRESTORE] 🔍 DEBUG: Error parsing subcategory document ${doc.id}: $e');
              print('[MART FIRESTORE] 🔍 DEBUG: Document data: ${doc.data()}');
              return null;
            }
          })
          .whereType<MartSubcategoryModel>()
          .toList();

      print(
          '[MART FIRESTORE] 🔍 DEBUG: Successfully parsed ${subcategories.length} subcategories from Firestore');

      return subcategories;
    } catch (e) {
      print(
          '[MART FIRESTORE] 🔍 DEBUG: Error fetching all subcategories from Firestore: $e');
      return [];
    }
  }

  /// Get categories by section from Firestore
  Future<List<MartCategoryModel>> getCategoriesBySection({
    required String section,
    int limit = 50,
  }) async {
    try {
      print('[MART FIRESTORE] 📂 Fetching categories for section: "$section"');

      // Query Firestore for categories in specific section using the composite index
      final querySnapshot = await _firestore
          .collection('mart_categories')
          .where('publish', isEqualTo: true)
          .where('section', isEqualTo: section)
          .orderBy('section_order', descending: false)
          .limit(limit)
          .get();

      print(
          '[MART FIRESTORE] 📂 Firestore query completed, found ${querySnapshot.docs.length} categories for section "$section"');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No categories found for section: $section');
        return [];
      }

      // Convert Firestore documents to MartCategoryModel
      final categories = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              final Map<String, dynamic> categoryData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              categoryData['id'] = doc.id;

              // Handle array fields that might be null
              if (categoryData['review_attributes'] == null)
                categoryData['review_attributes'] = [];

              // Handle numeric fields that might be strings
              if (categoryData['category_order'] is String) {
                categoryData['category_order'] =
                    int.tryParse(categoryData['category_order']) ?? 0;
              }
              if (categoryData['section_order'] is String) {
                categoryData['section_order'] =
                    int.tryParse(categoryData['section_order']) ?? 0;
              }

              return MartCategoryModel.fromJson(categoryData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore category document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartCategoryModel>()
          .toList();

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${categories.length} categories for section "$section" (server-side ordered)');
      return categories;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching categories for section "$section": $e');
      return [];
    }
  }

  /// Search subcategories by name or description
  Future<List<MartSubcategoryModel>> searchSubcategories({
    required String searchQuery,
    int limit = 20,
  }) async {
    try {
      print('[MART FIRESTORE] 🔍 Searching for subcategories: "$searchQuery"');

      // Convert search query to lowercase for case-insensitive search
      final query = searchQuery.toLowerCase();

      // Query Firestore for subcategories
      final querySnapshot = await _firestore
          .collection('mart_subcategories')
          .where('publish', isEqualTo: true)
          .limit(limit)
          .get();

      print(
          '[MART FIRESTORE] 🔍 Firestore query completed, found ${querySnapshot.docs.length} subcategories');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No subcategories found in Firestore');
        return [];
      }

      // Filter subcategories by search query and convert to MartSubcategoryModel
      final subcategories = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              // Add document ID to the data
              data['id'] = doc.id;

              return MartSubcategoryModel.fromJson(data);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore subcategory document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartSubcategoryModel>()
          .toList();

      // Filter by search query (title or description)
      final searchResults = subcategories.where((subcategory) {
        final title = (subcategory.title ?? '').toLowerCase();
        final description = (subcategory.description ?? '').toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();

      print(
          '[MART FIRESTORE] ✅ Search completed, found ${searchResults.length} matching subcategories');

      // Debug: Log the search results
      for (int i = 0; i < searchResults.length; i++) {
        final subcategory = searchResults[i];
        final title = subcategory.title ?? 'No Title';
        final description = subcategory.description ?? 'No Description';
        final shortDescription = description.length > 50
            ? '${description.substring(0, 50)}...'
            : description;
        print('[MART FIRESTORE]   ${i + 1}. $title - $shortDescription');
      }

      return searchResults;
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error searching subcategories: $e');
      return [];
    }
  }

  /// Search categories by title or description
  Future<List<MartCategoryModel>> searchCategories({
    required String searchQuery,
    int limit = 20,
  }) async {
    try {
      print('[MART FIRESTORE] 🔍 Searching for categories: "$searchQuery"');

      // Convert search query to lowercase for case-insensitive search
      final query = searchQuery.toLowerCase();

      // Query Firestore for categories
      final querySnapshot = await _firestore
          .collection('mart_categories')
          .where('publish', isEqualTo: true)
          .limit(limit)
          .get();

      print(
          '[MART FIRESTORE] 🔍 Firestore query completed, found ${querySnapshot.docs.length} categories');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No categories found in Firestore');
        return [];
      }

      // Filter categories by search query and convert to MartCategoryModel
      final categories = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              final Map<String, dynamic> categoryData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              categoryData['id'] = doc.id;

              // Handle array fields that might be null
              if (categoryData['review_attributes'] == null)
                categoryData['review_attributes'] = [];

              // Handle numeric fields that might be strings
              if (categoryData['category_order'] is String) {
                categoryData['category_order'] =
                    int.tryParse(categoryData['category_order']) ?? 0;
              }
              if (categoryData['section_order'] is String) {
                categoryData['section_order'] =
                    int.tryParse(categoryData['section_order']) ?? 0;
              }

              return MartCategoryModel.fromJson(categoryData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore category document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartCategoryModel>()
          .toList();

      // Filter by search query (title or description)
      final searchResults = categories.where((category) {
        final title = category.title?.toLowerCase() ?? '';
        final description = category.description?.toLowerCase() ?? '';
        return title.contains(query) || description.contains(query);
      }).toList();

      print(
          '[MART FIRESTORE] ✅ Search completed, found ${searchResults.length} matching categories');

      // Debug: Log the search results
      for (int i = 0; i < searchResults.length; i++) {
        final category = searchResults[i];
        final title = category.title ?? 'No Title';
        final description = category.description ?? 'No Description';
        final shortDescription = description.length > 50
            ? '${description.substring(0, 50)}...'
            : description;
        print('[MART FIRESTORE]   ${i + 1}. $title - $shortDescription');
      }

      return searchResults;
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error searching categories: $e');
      return [];
    }
  }

  /// Get items by category from Firestore
  Future<List<MartItemModel>> getItemsByCategory({
    required String categoryId,
    String? subcategoryId,
    String? searchQuery,
    int limit = 100,
  }) async {
    try {
      print('[MART FIRESTORE] 🛍️ Fetching items for category: $categoryId');
      if (subcategoryId != null) {
        print('[MART FIRESTORE] 🛍️ Subcategory filter: $subcategoryId');
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        print('[MART FIRESTORE] 🛍️ Search query: $searchQuery');
      }

      // Build the query
      Query query =
          _firestore.collection('mart_items').where('publish', isEqualTo: true);

      // Add category filter
      if (categoryId.isNotEmpty) {
        query = query.where('categoryID', isEqualTo: categoryId);
      }

      // Add subcategory filter if provided
      if (subcategoryId != null && subcategoryId.isNotEmpty) {
        query = query.where('subcategoryID', arrayContains: subcategoryId);
      }

      // Execute the query
      final querySnapshot = await query.limit(limit).get();

      print(
          '[MART FIRESTORE] 🛍️ Firestore query completed, found ${querySnapshot.docs.length} items');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No items found for category: $categoryId');
        return [];
      }

      // Convert Firestore documents to MartItemModel
      final items = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data == null) {
                print(
                    '[MART FIRESTORE] ⚠️ Document data is null for ${doc.id}');
                return null;
              }

              // Ensure data is a Map<String, dynamic>
              if (data is! Map<String, dynamic>) {
                print(
                    '[MART FIRESTORE] ⚠️ Document data is not a Map for ${doc.id}, type: ${data.runtimeType}');
                return null;
              }

              final Map<String, dynamic> itemData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              itemData['id'] = doc.id;

              // Handle array fields that might be null
              if (itemData['addOnsPrice'] == null) itemData['addOnsPrice'] = [];
              if (itemData['addOnsTitle'] == null) itemData['addOnsTitle'] = [];
              if (itemData['options'] == null) itemData['options'] = [];
              if (itemData['photos'] == null) itemData['photos'] = [];
              if (itemData['review_attributes'] == null)
                itemData['review_attributes'] = [];
              if (itemData['subcategoryID'] == null)
                itemData['subcategoryID'] = [];
              if (itemData['variants'] == null) itemData['variants'] = [];
              if (itemData['attributes'] == null) itemData['attributes'] = [];
              if (itemData['tags'] == null) itemData['tags'] = [];
              if (itemData['allergens'] == null) itemData['allergens'] = [];
              if (itemData['nutritionalInfo'] == null)
                itemData['nutritionalInfo'] = [];

              // Handle numeric fields that might be strings
              if (itemData['reviewCount'] is String) {
                itemData['reviewCount'] =
                    int.tryParse(itemData['reviewCount']) ?? 0;
              }
              if (itemData['reviewSum'] is String) {
                itemData['reviewSum'] =
                    int.tryParse(itemData['reviewSum']) ?? 0;
              }
              if (itemData['price'] is String) {
                itemData['price'] = double.tryParse(itemData['price']) ?? 0.0;
              }
              if (itemData['disPrice'] is String) {
                itemData['disPrice'] =
                    double.tryParse(itemData['disPrice']) ?? 0.0;
              }
              if (itemData['calories'] is String) {
                itemData['calories'] = int.tryParse(itemData['calories']) ?? 0;
              }
              if (itemData['proteins'] is String) {
                itemData['proteins'] = int.tryParse(itemData['proteins']) ?? 0;
              }
              if (itemData['fats'] is String) {
                itemData['fats'] = int.tryParse(itemData['fats']) ?? 0;
              }
              if (itemData['grams'] is String) {
                itemData['grams'] = int.tryParse(itemData['grams']) ?? 0;
              }

              return MartItemModel.fromJson(itemData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore item document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartItemModel>()
          .toList();

      // Apply search filter on client side if needed
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        items.removeWhere((item) =>
            !item.name.toLowerCase().contains(searchLower) &&
            !item.description.toLowerCase().contains(searchLower));
        print(
            '[MART FIRESTORE] 🔍 After search filtering: ${items.length} items');
      }

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${items.length} items from Firestore');

      return items;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching items by category from Firestore: $e');
      return [];
    }
  }

  /// Get mart vendors from Firestore
  Future<List<MartVendorModel>> getMartVendors({
    String? search,
    bool? isActive,
    bool? enabledDelivery,
    int limit = 20,
  }) async {
    try {
      print('[MART FIRESTORE] 🏪 Fetching mart vendors from Firestore...');

      // Query Firestore for vendors
      Query query = _firestore.collection('mart_vendors');

      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      if (enabledDelivery != null) {
        query = query.where('enabledDelivery', isEqualTo: enabledDelivery);
      }

      // Execute the query
      final querySnapshot = await query.limit(limit).get();

      print(
          '[MART FIRESTORE] 🏪 Firestore query completed, found ${querySnapshot.docs.length} vendors');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No vendors found in Firestore');
        return [];
      }

      // Convert Firestore documents to MartVendorModel
      final vendors = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data == null) {
                print(
                    '[MART FIRESTORE] ⚠️ Document data is null for ${doc.id}');
                return null;
              }

              // Ensure data is a Map<String, dynamic>
              if (data is! Map<String, dynamic>) {
                print(
                    '[MART FIRESTORE] ⚠️ Document data is not a Map for ${doc.id}, type: ${data.runtimeType}');
                return null;
              }

              final Map<String, dynamic> vendorData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              vendorData['id'] = doc.id;

              return MartVendorModel.fromJson(vendorData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore vendor document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartVendorModel>()
          .toList();

      // Apply search filter on client side if needed
      if (search != null && search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        vendors.removeWhere((vendor) =>
            vendor.name != null &&
            !vendor.name!.toLowerCase().contains(searchLower));
        print(
            '[MART FIRESTORE] 🔍 After search filtering: ${vendors.length} vendors');
      }

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${vendors.length} vendors from Firestore');

      return vendors;
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error fetching vendors from Firestore: $e');
      return [];
    }
  }

  /// Get published categories from Firestore
  Future<List<MartCategoryModel>> getPublishedCategories(
      {String? martId}) async {
    try {
      print(
          '[MART FIRESTORE] 📂 Fetching published categories from Firestore...');

      // Query Firestore for published categories
      Query query = _firestore
          .collection('mart_categories')
          .where('publish', isEqualTo: true);

      if (martId != null && martId.isNotEmpty) {
        query = query.where('mart_id', isEqualTo: martId);
      }

      final querySnapshot = await query.limit(100).get();

      print(
          '[MART FIRESTORE] 📂 Firestore query completed, found ${querySnapshot.docs.length} published categories');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No published categories found');
        return [];
      }

      // Convert Firestore documents to MartCategoryModel
      final categories = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data == null) return null;

              // Ensure data is a Map<String, dynamic>
              if (data is! Map<String, dynamic>) {
                print(
                    '[MART FIRESTORE] ⚠️ Document data is not a Map for ${doc.id}, type: ${data.runtimeType}');
                return null;
              }

              final Map<String, dynamic> categoryData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              categoryData['id'] = doc.id;

              // Handle array fields that might be null
              if (categoryData['review_attributes'] == null)
                categoryData['review_attributes'] = [];

              // Handle numeric fields that might be strings
              if (categoryData['category_order'] is String) {
                categoryData['category_order'] =
                    int.tryParse(categoryData['category_order']) ?? 0;
              }
              if (categoryData['section_order'] is String) {
                categoryData['section_order'] =
                    int.tryParse(categoryData['section_order']) ?? 0;
              }

              return MartCategoryModel.fromJson(categoryData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore category document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartCategoryModel>()
          .toList();

      // Sort categories by category_order
      categories.sort(
          (a, b) => (a.categoryOrder ?? 0).compareTo(b.categoryOrder ?? 0));

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${categories.length} published categories from Firestore');

      return categories;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching published categories from Firestore: $e');
      return [];
    }
  }

  /// Get featured categories from Firestore
  Future<List<MartCategoryModel>> getFeaturedCategories(
      {String? martId}) async {
    try {
      print(
          '[MART FIRESTORE] ⭐ Fetching featured categories from Firestore...');

      // Query Firestore for featured categories
      Query query = _firestore
          .collection('mart_categories')
          .where('publish', isEqualTo: true)
          .where('isFeature', isEqualTo: true);

      if (martId != null && martId.isNotEmpty) {
        query = query.where('mart_id', isEqualTo: martId);
      }

      final querySnapshot = await query.limit(50).get();

      print(
          '[MART FIRESTORE] ⭐ Firestore query completed, found ${querySnapshot.docs.length} featured categories');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No featured categories found');
        return [];
      }

      // Convert Firestore documents to MartCategoryModel
      final categories = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data == null) return null;

              // Ensure data is a Map<String, dynamic>
              if (data is! Map<String, dynamic>) {
                print(
                    '[MART FIRESTORE] ⚠️ Document data is not a Map for ${doc.id}, type: ${data.runtimeType}');
                return null;
              }

              final Map<String, dynamic> categoryData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              categoryData['id'] = doc.id;

              // Handle array fields that might be null
              if (categoryData['review_attributes'] == null)
                categoryData['review_attributes'] = [];

              // Handle numeric fields that might be strings
              if (categoryData['category_order'] is String) {
                categoryData['category_order'] =
                    int.tryParse(categoryData['category_order']) ?? 0;
              }
              if (categoryData['section_order'] is String) {
                categoryData['section_order'] =
                    int.tryParse(categoryData['section_order']) ?? 0;
              }

              return MartCategoryModel.fromJson(categoryData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore category document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartCategoryModel>()
          .toList();

      // Sort categories by category_order
      categories.sort(
          (a, b) => (a.categoryOrder ?? 0).compareTo(b.categoryOrder ?? 0));

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${categories.length} featured categories from Firestore');

      return categories;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching featured categories from Firestore: $e');
      return [];
    }
  }

  /// Get items by vendor from Firestore
  Future<List<MartItemModel>> getItemsByVendor({
    required String vendorId,
    String? categoryId,
    bool? isAvailable,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('[MART FIRESTORE] 🏪 Fetching items for vendor: $vendorId');

      // Query Firestore for items by vendor
      Query query = _firestore
          .collection('mart_items')
          .where('publish', isEqualTo: true)
          .where('vendorID', isEqualTo: vendorId);

      if (isAvailable != null) {
        query = query.where('isAvailable', isEqualTo: isAvailable);
      }

      final querySnapshot = await query.limit(limit).get();

      print(
          '[MART FIRESTORE] 🏪 Firestore query completed, found ${querySnapshot.docs.length} items for vendor');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No items found for vendor: $vendorId');
        return [];
      }

      // Convert Firestore documents to MartItemModel
      final items = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data == null) return null;

              // Ensure data is a Map<String, dynamic>
              if (data is! Map<String, dynamic>) {
                print(
                    '[MART FIRESTORE] ⚠️ Document data is not a Map for ${doc.id}, type: ${data.runtimeType}');
                return null;
              }

              final Map<String, dynamic> itemData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              itemData['id'] = doc.id;

              // Handle array fields that might be null
              if (itemData['addOnsPrice'] == null) itemData['addOnsPrice'] = [];
              if (itemData['addOnsTitle'] == null) itemData['addOnsTitle'] = [];
              if (itemData['options'] == null) itemData['options'] = [];
              if (itemData['photos'] == null) itemData['photos'] = [];
              if (itemData['review_attributes'] == null)
                itemData['review_attributes'] = [];
              if (itemData['subcategoryID'] == null)
                itemData['subcategoryID'] = [];

              // Handle numeric fields that might be strings
              if (itemData['reviewCount'] is String) {
                itemData['reviewCount'] =
                    int.tryParse(itemData['reviewCount']) ?? 0;
              }
              if (itemData['reviewSum'] is String) {
                itemData['reviewSum'] =
                    int.tryParse(itemData['reviewSum']) ?? 0;
              }
              if (itemData['price'] is String) {
                itemData['price'] = double.tryParse(itemData['price']) ?? 0.0;
              }

              return MartItemModel.fromJson(itemData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore item document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartItemModel>()
          .toList();

      // Filter by category if provided
      if (categoryId != null && categoryId.isNotEmpty) {
        items.removeWhere((item) => item.categoryID != categoryId);
        print(
            '[MART FIRESTORE] 🔍 After category filtering: ${items.length} items');
      }

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${items.length} items for vendor from Firestore');

      return items;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching items by vendor from Firestore: $e');
      return [];
    }
  }

  /// Get items by category only from Firestore
  Future<List<MartItemModel>> getItemsByCategoryOnly({
    required String categoryId,
    bool? isAvailable,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('[MART FIRESTORE] 📂 Fetching items for category: $categoryId');

      // Query Firestore for items by category
      Query query = _firestore
          .collection('mart_items')
          .where('publish', isEqualTo: true)
          .where('categoryID', isEqualTo: categoryId);

      if (isAvailable != null) {
        query = query.where('isAvailable', isEqualTo: isAvailable);
      }

      final querySnapshot = await query.limit(limit).get();

      print(
          '[MART FIRESTORE] 📂 Firestore query completed, found ${querySnapshot.docs.length} items for category');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No items found for category: $categoryId');
        return [];
      }

      // Convert Firestore documents to MartItemModel
      final items = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data == null) return null;

              // Ensure data is a Map<String, dynamic>
              if (data is! Map<String, dynamic>) {
                print(
                    '[MART FIRESTORE] ⚠️ Document data is not a Map for ${doc.id}, type: ${data.runtimeType}');
                return null;
              }

              final Map<String, dynamic> itemData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              itemData['id'] = doc.id;

              // Handle array fields that might be null
              if (itemData['addOnsPrice'] == null) itemData['addOnsPrice'] = [];
              if (itemData['addOnsTitle'] == null) itemData['addOnsTitle'] = [];
              if (itemData['options'] == null) itemData['options'] = [];
              if (itemData['photos'] == null) itemData['photos'] = [];
              if (itemData['review_attributes'] == null)
                itemData['review_attributes'] = [];
              if (itemData['subcategoryID'] == null)
                itemData['subcategoryID'] = [];

              // Handle numeric fields that might be strings
              if (itemData['reviewCount'] is String) {
                itemData['reviewCount'] =
                    int.tryParse(itemData['reviewCount']) ?? 0;
              }
              if (itemData['reviewSum'] is String) {
                itemData['reviewSum'] =
                    int.tryParse(itemData['reviewSum']) ?? 0;
              }
              if (itemData['price'] is String) {
                itemData['price'] = double.tryParse(itemData['price']) ?? 0.0;
              }

              return MartItemModel.fromJson(itemData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore item document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartItemModel>()
          .toList();

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${items.length} items for category from Firestore');

      return items;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching items by category only from Firestore: $e');
      return [];
    }
  }

  /// Get unique sections from mart_items collection (optimized for speed)
  Future<List<String>> getUniqueSections() async {
    try {
      print(
          '[MART FIRESTORE] 📂 Fetching unique sections from mart_items (OPTIMIZED)...');

      // Query Firestore with smaller limit for faster response (we only need a sample to get sections)
      final querySnapshot = await _firestore
          .collection('mart_items')
          .where('publish', isEqualTo: true)
          .limit(50) // Reduced limit for faster response
          .get()
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('[MART FIRESTORE] ⏰ Sections query timeout');
          throw TimeoutException(
              'Sections query timeout', const Duration(seconds: 5));
        },
      );

      print(
          '[MART FIRESTORE] 📂 Firestore query completed, found ${querySnapshot.docs.length} items');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No items found');
        return [];
      }

      // Extract unique sections
      Set<String> uniqueSections = {};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final section = data['section'] as String?;
        if (section != null && section.isNotEmpty) {
          uniqueSections.add(section);
        }
      }
      //
      final sections = uniqueSections.toList()..sort();
      // final sections = uniqueSections.toList();
      print(
          '[MART FIRESTORE] ✅ Found ${sections.length} unique sections: $sections');

      // Debug: Print each section individually
      for (int i = 0; i < sections.length; i++) {
        print('[MART FIRESTORE] 📂 Section ${i + 1}: "${sections[i]}"');
      }

      return sections;
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error fetching unique sections: $e');
      return [];
    }
  }

  /// Get items by section from Firestore
  Future<List<MartItemModel>> getItemsBySection({
    required String section,
    int limit = 15,
  }) async {
    try {
      print('[MART FIRESTORE] 🛍️ Fetching items for section: $section');

      // Query Firestore for items by section
      final querySnapshot = await _firestore
          .collection('mart_items')
          .where('publish', isEqualTo: true)
          .where('section', isEqualTo: section)
          .limit(limit)
          .get();

      print(
          '[MART FIRESTORE] 🛍️ Firestore query completed, found ${querySnapshot.docs.length} items for section "$section"');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No items found for section: $section');
        return [];
      }

      // Convert Firestore documents to MartItemModel
      final items = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              final Map<String, dynamic> itemData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              itemData['id'] = doc.id;

              // Handle array fields that might be null
              if (itemData['addOnsPrice'] == null) itemData['addOnsPrice'] = [];
              if (itemData['addOnsTitle'] == null) itemData['addOnsTitle'] = [];
              if (itemData['options'] == null) itemData['options'] = [];
              if (itemData['photos'] == null) itemData['photos'] = [];
              if (itemData['subcategoryID'] == null)
                itemData['subcategoryID'] = '';
              if (itemData['product_specification'] == null)
                itemData['product_specification'] = {};

              // Handle numeric fields that might be strings
              if (itemData['reviewCount'] is String) {
                itemData['reviewCount'] =
                    int.tryParse(itemData['reviewCount']) ?? 0;
              }
              if (itemData['reviewSum'] is String) {
                itemData['reviewSum'] =
                    double.tryParse(itemData['reviewSum']) ?? 0.0;
              }
              if (itemData['price'] is String) {
                itemData['price'] = double.tryParse(itemData['price']) ?? 0.0;
              }
              if (itemData['disPrice'] is String) {
                itemData['disPrice'] =
                    double.tryParse(itemData['disPrice']) ?? 0.0;
              }
              if (itemData['quantity'] is String) {
                itemData['quantity'] = int.tryParse(itemData['quantity']) ?? 0;
              }
              if (itemData['calories'] is String) {
                itemData['calories'] = int.tryParse(itemData['calories']) ?? 0;
              }
              if (itemData['proteins'] is String) {
                itemData['proteins'] =
                    double.tryParse(itemData['proteins']) ?? 0.0;
              }
              if (itemData['fats'] is String) {
                itemData['fats'] = double.tryParse(itemData['fats']) ?? 0.0;
              }
              if (itemData['grams'] is String) {
                itemData['grams'] = double.tryParse(itemData['grams']) ?? 0.0;
              }
              if (itemData['options_count'] is String) {
                itemData['options_count'] =
                    int.tryParse(itemData['options_count']) ?? 0;
              }

              // Handle boolean fields that might be null
              if (itemData['has_options'] == null)
                itemData['has_options'] = false;
              if (itemData['isAvailable'] == null)
                itemData['isAvailable'] = true;
              if (itemData['isBestSeller'] == null)
                itemData['isBestSeller'] = false;
              if (itemData['isFeature'] == null) itemData['isFeature'] = false;
              if (itemData['isNew'] == null) itemData['isNew'] = false;
              if (itemData['isSeasonal'] == null)
                itemData['isSeasonal'] = false;
              if (itemData['isSpotlight'] == null)
                itemData['isSpotlight'] = false;
              if (itemData['isStealOfMoment'] == null)
                itemData['isStealOfMoment'] = false;
              if (itemData['isTrending'] == null)
                itemData['isTrending'] = false;
              if (itemData['veg'] == null) itemData['veg'] = true;
              if (itemData['nonveg'] == null) itemData['nonveg'] = false;
              if (itemData['takeawayOption'] == null)
                itemData['takeawayOption'] = false;
              if (itemData['publish'] == null) itemData['publish'] = true;

              return MartItemModel.fromJson(itemData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore item document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartItemModel>()
          .toList();

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${items.length} items for section "$section"');
      return items;
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error fetching items by section: $e');
      return [];
    }
  }

  /// Get all mart items from Firestore
  Future<List<MartItemModel>> getMartItems({
    String? search,
    int limit = 100,
  }) async {
    try {
      print('[MART FIRESTORE] 🛍️ Fetching all mart items from Firestore...');

      // Query Firestore for all items
      Query query =
          _firestore.collection('mart_items').where('publish', isEqualTo: true);

      final querySnapshot = await query.limit(limit).get();

      print(
          '[MART FIRESTORE] 🛍️ Firestore query completed, found ${querySnapshot.docs.length} items');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No items found in Firestore');
        return [];
      }

      // Convert Firestore documents to MartItemModel
      final items = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              if (data == null) return null;

              // Ensure data is a Map<String, dynamic>
              if (data is! Map<String, dynamic>) {
                print(
                    '[MART FIRESTORE] ⚠️ Document data is not a Map for ${doc.id}, type: ${data.runtimeType}');
                return null;
              }

              final Map<String, dynamic> itemData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              itemData['id'] = doc.id;

              // Handle array fields that might be null
              if (itemData['addOnsPrice'] == null) itemData['addOnsPrice'] = [];
              if (itemData['addOnsTitle'] == null) itemData['addOnsTitle'] = [];
              if (itemData['options'] == null) itemData['options'] = [];
              if (itemData['photos'] == null) itemData['photos'] = [];
              if (itemData['review_attributes'] == null)
                itemData['review_attributes'] = [];
              if (itemData['subcategoryID'] == null)
                itemData['subcategoryID'] = [];

              // Handle numeric fields that might be strings
              if (itemData['reviewCount'] is String) {
                itemData['reviewCount'] =
                    int.tryParse(itemData['reviewCount']) ?? 0;
              }
              if (itemData['reviewSum'] is String) {
                itemData['reviewSum'] =
                    int.tryParse(itemData['reviewSum']) ?? 0;
              }
              if (itemData['price'] is String) {
                itemData['price'] = double.tryParse(itemData['price']) ?? 0.0;
              }

              return MartItemModel.fromJson(itemData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore item document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartItemModel>()
          .toList();

      // Apply search filter on client side if needed
      if (search != null && search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        items.removeWhere((item) =>
            !item.name.toLowerCase().contains(searchLower) &&
            !item.description.toLowerCase().contains(searchLower));
        print(
            '[MART FIRESTORE] 🔍 After search filtering: ${items.length} items');
      }

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${items.length} mart items from Firestore');

      return items;
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error fetching mart items from Firestore: $e');
      return [];
    }
  }

  /// Get categories with subcategories from Firestore
  Future<List<MartCategoryModel>> getCategoriesWithSubcategories(
      {int limit = 50}) async {
    try {
      print(
          '[MART FIRESTORE] 📂 Fetching categories with subcategories from Firestore...');

      // Query Firestore for categories
      final querySnapshot = await _firestore
          .collection('mart_categories')
          .where('publish', isEqualTo: true)
          .limit(limit)
          .get();

      print(
          '[MART FIRESTORE] 📂 Firestore query completed, found ${querySnapshot.docs.length} categories');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No categories found in Firestore');
        return [];
      }

      // Convert Firestore documents to MartCategoryModel
      final categories = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              final Map<String, dynamic> categoryData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              categoryData['id'] = doc.id;

              // Handle array fields that might be null
              if (categoryData['review_attributes'] == null)
                categoryData['review_attributes'] = [];

              // Handle numeric fields that might be strings
              if (categoryData['category_order'] is String) {
                categoryData['category_order'] =
                    int.tryParse(categoryData['category_order']) ?? 0;
              }
              if (categoryData['section_order'] is String) {
                categoryData['section_order'] =
                    int.tryParse(categoryData['section_order']) ?? 0;
              }

              return MartCategoryModel.fromJson(categoryData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore category document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartCategoryModel>()
          .toList();

      // Sort categories by category_order
      categories.sort(
          (a, b) => (a.categoryOrder ?? 0).compareTo(b.categoryOrder ?? 0));

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${categories.length} categories with subcategories from Firestore');

      return categories;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching categories with subcategories from Firestore: $e');
      return [];
    }
  }

  /// Get filtered categories from Firestore
  Future<List<MartCategoryModel>> getFilteredCategories({
    String? search,
    int limit = 50,
  }) async {
    try {
      print(
          '[MART FIRESTORE] 🔍 Fetching filtered categories from Firestore...');

      // Query Firestore for categories
      final querySnapshot = await _firestore
          .collection('mart_categories')
          .where('publish', isEqualTo: true)
          .limit(limit)
          .get();

      print(
          '[MART FIRESTORE] 🔍 Firestore query completed, found ${querySnapshot.docs.length} categories');

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ No categories found in Firestore');
        return [];
      }

      // Convert Firestore documents to MartCategoryModel
      final categories = querySnapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              final Map<String, dynamic> categoryData =
                  Map<String, dynamic>.from(data);

              // Add document ID to the data
              categoryData['id'] = doc.id;

              // Handle array fields that might be null
              if (categoryData['review_attributes'] == null)
                categoryData['review_attributes'] = [];

              // Handle numeric fields that might be strings
              if (categoryData['category_order'] is String) {
                categoryData['category_order'] =
                    int.tryParse(categoryData['category_order']) ?? 0;
              }
              if (categoryData['section_order'] is String) {
                categoryData['section_order'] =
                    int.tryParse(categoryData['section_order']) ?? 0;
              }

              return MartCategoryModel.fromJson(categoryData);
            } catch (e) {
              print(
                  '[MART FIRESTORE] ❌ Error parsing Firestore category document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<MartCategoryModel>()
          .toList();

      // Apply search filter on client side if needed
      if (search != null && search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        categories.removeWhere((category) =>
            !(category.title?.toLowerCase().contains(searchLower) ?? false) &&
            !(category.description?.toLowerCase().contains(searchLower) ??
                false));
        print(
            '[MART FIRESTORE] 🔍 After search filtering: ${categories.length} categories');
      }

      // Sort categories by category_order
      categories.sort(
          (a, b) => (a.categoryOrder ?? 0).compareTo(b.categoryOrder ?? 0));

      print(
          '[MART FIRESTORE] ✅ Successfully parsed ${categories.length} filtered categories from Firestore');

      return categories;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error fetching filtered categories from Firestore: $e');
      return [];
    }
  }

  /// Get category by ID from Firestore
  Future<MartCategoryModel?> getCategoryById(String categoryId) async {
    try {
      print('[MART FIRESTORE] 🔍 Getting category by ID: $categoryId');

      // Query Firestore for the specific category
      final docSnapshot =
          await _firestore.collection('mart_categories').doc(categoryId).get();

      if (!docSnapshot.exists) {
        print('[MART FIRESTORE] ⚠️ Category not found: $categoryId');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        print('[MART FIRESTORE] ⚠️ Category data is null for: $categoryId');
        return null;
      }

      // Ensure data is a Map<String, dynamic>
      if (data is! Map<String, dynamic>) {
        print(
            '[MART FIRESTORE] ⚠️ Category data is not a Map for $categoryId, type: ${data.runtimeType}');
        return null;
      }

      final Map<String, dynamic> categoryData = Map<String, dynamic>.from(data);

      // Add document ID to the data
      categoryData['id'] = docSnapshot.id;

      // Handle array fields that might be null
      if (categoryData['review_attributes'] == null)
        categoryData['review_attributes'] = [];

      // Handle numeric fields that might be strings
      if (categoryData['category_order'] is String) {
        categoryData['category_order'] =
            int.tryParse(categoryData['category_order']) ?? 0;
      }
      if (categoryData['section_order'] is String) {
        categoryData['section_order'] =
            int.tryParse(categoryData['section_order']) ?? 0;
      }

      final category = MartCategoryModel.fromJson(categoryData);
      print(
          '[MART FIRESTORE] ✅ Successfully retrieved category: ${category.title}');

      return category;
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error getting category by ID $categoryId: $e');
      return null;
    }
  }

  /// Get mart vendor details from Firestore
  Future<MartVendorModel?> getMartVendorDetails(String vendorId) async {
    try {
      print('[MART FIRESTORE] 🏪 Getting vendor details: $vendorId');

      // Query Firestore for the specific vendor
      final docSnapshot =
          await _firestore.collection('mart_vendors').doc(vendorId).get();

      if (!docSnapshot.exists) {
        print('[MART FIRESTORE] ⚠️ Vendor not found: $vendorId');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        print('[MART FIRESTORE] ⚠️ Vendor data is null for: $vendorId');
        return null;
      }

      // Ensure data is a Map<String, dynamic>
      if (data is! Map<String, dynamic>) {
        print(
            '[MART FIRESTORE] ⚠️ Vendor data is not a Map for $vendorId, type: ${data.runtimeType}');
        return null;
      }

      final Map<String, dynamic> vendorData = Map<String, dynamic>.from(data);

      // Add document ID to the data
      vendorData['id'] = docSnapshot.id;

      final vendor = MartVendorModel.fromJson(vendorData);
      print('[MART FIRESTORE] ✅ Successfully retrieved vendor: ${vendor.name}');

      return vendor;
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error getting vendor details $vendorId: $e');
      return null;
    }
  }

  /// Get category details from Firestore
  Future<MartCategoryModel?> getCategoryDetails(String categoryId) async {
    try {
      print('[MART FIRESTORE] 📂 Getting category details: $categoryId');

      // Query Firestore for the specific category
      final docSnapshot =
          await _firestore.collection('mart_categories').doc(categoryId).get();

      if (!docSnapshot.exists) {
        print('[MART FIRESTORE] ⚠️ Category not found: $categoryId');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        print('[MART FIRESTORE] ⚠️ Category data is null for: $categoryId');
        return null;
      }

      // Ensure data is a Map<String, dynamic>
      if (data is! Map<String, dynamic>) {
        print(
            '[MART FIRESTORE] ⚠️ Category data is not a Map for $categoryId, type: ${data.runtimeType}');
        return null;
      }

      final Map<String, dynamic> categoryData = Map<String, dynamic>.from(data);

      // Add document ID to the data
      categoryData['id'] = docSnapshot.id;

      // Handle array fields that might be null
      if (categoryData['review_attributes'] == null)
        categoryData['review_attributes'] = [];

      // Handle numeric fields that might be strings
      if (categoryData['category_order'] is String) {
        categoryData['category_order'] =
            int.tryParse(categoryData['category_order']) ?? 0;
      }
      if (categoryData['section_order'] is String) {
        categoryData['section_order'] =
            int.tryParse(categoryData['section_order']) ?? 0;
      }

      final category = MartCategoryModel.fromJson(categoryData);
      print(
          '[MART FIRESTORE] ✅ Successfully retrieved category details: ${category.title}');

      return category;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error getting category details $categoryId: $e');
      return null;
    }
  }

  /// Get item by ID from Firestore
  Future<MartItemModel?> getItemById(String itemId) async {
    try {
      print('[MART FIRESTORE] 🔍 Getting item by ID: $itemId');

      // First try to get by document ID (in case the document ID matches the product ID)
      final docSnapshot =
          await _firestore.collection('mart_items').doc(itemId).get();

      if (docSnapshot.exists) {
        print('[MART FIRESTORE] ✅ Found item by document ID: $itemId');
        final data = docSnapshot.data();
        if (data != null) {
          final Map<String, dynamic> itemData = Map<String, dynamic>.from(data);
          itemData['id'] = docSnapshot.id;
          return MartItemModel.fromJson(itemData);
        }
      }

      // If not found by document ID, try to find by 'id' field
      print(
          '[MART FIRESTORE] 🔍 Document ID not found, searching by id field: $itemId');
      final querySnapshot = await _firestore
          .collection('mart_items')
          .where('id', isEqualTo: itemId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('[MART FIRESTORE] ⚠️ Item not found by id field: $itemId');
        return null;
      }

      print('[MART FIRESTORE] ✅ Found item by id field: $itemId');
      final doc = querySnapshot.docs.first;

      final data = doc.data();
      if (data == null) {
        print('[MART FIRESTORE] ⚠️ Item data is null for: $itemId');
        return null;
      }

      // Ensure data is a Map<String, dynamic>
      if (data is! Map<String, dynamic>) {
        print(
            '[MART FIRESTORE] ⚠️ Item data is not a Map for $itemId, type: ${data.runtimeType}');
        return null;
      }

      final Map<String, dynamic> itemData = Map<String, dynamic>.from(data);

      // Add document ID to the data
      itemData['id'] = doc.id;

      // Handle array fields that might be null
      if (itemData['addOnsPrice'] == null) itemData['addOnsPrice'] = [];
      if (itemData['addOnsTitle'] == null) itemData['addOnsTitle'] = [];
      if (itemData['options'] == null) itemData['options'] = [];
      if (itemData['photos'] == null) itemData['photos'] = [];
      if (itemData['review_attributes'] == null)
        itemData['review_attributes'] = [];
      if (itemData['subcategoryID'] == null) itemData['subcategoryID'] = [];
      if (itemData['variants'] == null) itemData['variants'] = [];
      if (itemData['attributes'] == null) itemData['attributes'] = [];
      if (itemData['tags'] == null) itemData['tags'] = [];
      if (itemData['allergens'] == null) itemData['allergens'] = [];
      if (itemData['nutritionalInfo'] == null) itemData['nutritionalInfo'] = [];

      // Handle numeric fields that might be strings
      if (itemData['reviewCount'] is String) {
        itemData['reviewCount'] = int.tryParse(itemData['reviewCount']) ?? 0;
      }
      if (itemData['reviewSum'] is String) {
        itemData['reviewSum'] = int.tryParse(itemData['reviewSum']) ?? 0;
      }
      if (itemData['price'] is String) {
        itemData['price'] = double.tryParse(itemData['price']) ?? 0.0;
      }
      if (itemData['disPrice'] is String) {
        itemData['disPrice'] = double.tryParse(itemData['disPrice']) ?? 0.0;
      }

      final item = MartItemModel.fromJson(itemData);
      print('[MART FIRESTORE] ✅ Successfully retrieved item: ${item.name}');

      return item;
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error getting item by ID $itemId: $e');
      return null;
    }
  }

  /// Get item count for a category from Firestore
  Future<int> getItemCountForCategory(String categoryId) async {
    try {
      print('[MART FIRESTORE] 🔢 Getting item count for category: $categoryId');

      // Query Firestore for items in the category
      final querySnapshot = await _firestore
          .collection('mart_items')
          .where('categoryID', isEqualTo: categoryId)
          .where('publish', isEqualTo: true)
          .get();

      final count = querySnapshot.docs.length;
      print('[MART FIRESTORE] ✅ Category $categoryId has $count items');

      return count;
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error getting item count for category $categoryId: $e');
      return 0;
    }
  }

  /// Stream similar products by category from Firestore
  Stream<List<MartItemModel>> streamSimilarProducts({
    required String categoryId,
    String? subcategoryId,
    String? excludeProductId,
    bool? isAvailable,
    int limit = 6,
  }) {
    try {
      print(
          '[MART FIRESTORE] 📡 Starting stream for similar products - category: $categoryId');
      if (subcategoryId != null) {
        print('[MART FIRESTORE] 📡 Subcategory filter: $subcategoryId');
      }
      if (excludeProductId != null) {
        print('[MART FIRESTORE] 📡 Excluding product: $excludeProductId');
      }

      // Build the query
      Query query =
          _firestore.collection('mart_items').where('publish', isEqualTo: true);

      // Add category filter
      if (categoryId.isNotEmpty) {
        query = query.where('categoryID', isEqualTo: categoryId);
      }

      // Add subcategory filter if provided
      if (subcategoryId != null && subcategoryId.isNotEmpty) {
        // Updated: subcategoryID is now a string, not an array
        query = query.where('subcategoryID', isEqualTo: subcategoryId);
      }

      // Add availability filter if provided
      if (isAvailable != null) {
        query = query.where('isAvailable', isEqualTo: isAvailable);
      }

      // Apply limit
      query = query.limit(limit +
          (excludeProductId != null
              ? 1
              : 0)); // Get one extra in case we need to exclude

      // Return stream that converts Firestore snapshots to MartItemModel list
      return query.snapshots().map((snapshot) {
        print(
            '[MART FIRESTORE] 📡 Stream update: ${snapshot.docs.length} documents received');

        if (snapshot.docs.isEmpty) {
          print(
              '[MART FIRESTORE] ⚠️ No items found in stream for category: $categoryId');
          return <MartItemModel>[];
        }

        // Convert Firestore documents to MartItemModel
        final items = snapshot.docs
            .map((doc) {
              try {
                final itemData = doc.data() as Map<String, dynamic>;
                itemData['id'] = doc.id;

                // Handle numeric fields that might be strings
                if (itemData['reviewCount'] is String) {
                  itemData['reviewCount'] =
                      int.tryParse(itemData['reviewCount']) ?? 0;
                }
                if (itemData['reviewSum'] is String) {
                  itemData['reviewSum'] =
                      int.tryParse(itemData['reviewSum']) ?? 0;
                }
                if (itemData['price'] is String) {
                  itemData['price'] = double.tryParse(itemData['price']) ?? 0.0;
                }
                if (itemData['disPrice'] is String) {
                  itemData['disPrice'] =
                      double.tryParse(itemData['disPrice']) ?? 0.0;
                }
                if (itemData['calories'] is String) {
                  itemData['calories'] =
                      int.tryParse(itemData['calories']) ?? 0;
                }
                if (itemData['proteins'] is String) {
                  itemData['proteins'] =
                      int.tryParse(itemData['proteins']) ?? 0;
                }
                if (itemData['fats'] is String) {
                  itemData['fats'] = int.tryParse(itemData['fats']) ?? 0;
                }
                if (itemData['grams'] is String) {
                  itemData['grams'] = int.tryParse(itemData['grams']) ?? 0;
                }

                return MartItemModel.fromJson(itemData);
              } catch (e) {
                print(
                    '[MART FIRESTORE] ❌ Error parsing Firestore item document ${doc.id}: $e');
                return null;
              }
            })
            .whereType<MartItemModel>()
            .toList();

        // Exclude the current product if specified
        if (excludeProductId != null) {
          items.removeWhere((item) => item.id == excludeProductId);
        }

        // Limit to requested amount
        final finalItems = items.take(limit).toList();

        print(
            '[MART FIRESTORE] 📡 Stream returning ${finalItems.length} similar products');
        return finalItems;
      }).handleError((error) {
        print('[MART FIRESTORE] ❌ Stream error for similar products: $error');
        return <MartItemModel>[];
      });
    } catch (e) {
      print(
          '[MART FIRESTORE] ❌ Error creating stream for similar products: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Stream all products from mart_items collection
  Stream<List<MartItemModel>> streamAllProducts({
    String? excludeProductId,
    bool? isAvailable,
    int limit = 10,
  }) {
    try {
      print('[MART FIRESTORE] 📡 Starting stream for all products');
      if (excludeProductId != null) {
        print('[MART FIRESTORE] 📡 Excluding product: $excludeProductId');
      }

      // Build the query for all products
      Query query =
          _firestore.collection('mart_items').where('publish', isEqualTo: true);

      // Add availability filter if provided
      if (isAvailable != null) {
        query = query.where('isAvailable', isEqualTo: isAvailable);
      }

      // Apply limit
      query = query.limit(limit +
          (excludeProductId != null
              ? 1
              : 0)); // Get one extra in case we need to exclude

      // Return stream that converts Firestore snapshots to MartItemModel list
      return query.snapshots().map((snapshot) {
        print(
            '[MART FIRESTORE] 📡 Stream update: ${snapshot.docs.length} documents received');
        print('[MART FIRESTORE] 📡 Stream metadata: ${snapshot.metadata}');

        if (snapshot.docs.isEmpty) {
          print('[MART FIRESTORE] ⚠️ No items found in stream');
          return <MartItemModel>[];
        }

        // Convert Firestore documents to MartItemModel
        final items = <MartItemModel>[];
        for (final doc in snapshot.docs) {
          try {
            final itemData = doc.data() as Map<String, dynamic>;
            itemData['id'] = doc.id;

            print(
                '[MART FIRESTORE] 📡 Processing document ${doc.id}: ${itemData['name']}');

            // Handle numeric fields that might be strings
            if (itemData['reviewCount'] is String) {
              itemData['reviewCount'] =
                  int.tryParse(itemData['reviewCount']) ?? 0;
            }
            if (itemData['reviewSum'] is String) {
              itemData['reviewSum'] = int.tryParse(itemData['reviewSum']) ?? 0;
            }
            if (itemData['price'] is String) {
              itemData['price'] = double.tryParse(itemData['price']) ?? 0.0;
            }
            if (itemData['disPrice'] is String) {
              itemData['disPrice'] =
                  double.tryParse(itemData['disPrice']) ?? 0.0;
            }
            if (itemData['calories'] is String) {
              itemData['calories'] = int.tryParse(itemData['calories']) ?? 0;
            }
            if (itemData['proteins'] is String) {
              itemData['proteins'] = int.tryParse(itemData['proteins']) ?? 0;
            }
            if (itemData['fats'] is String) {
              itemData['fats'] = int.tryParse(itemData['fats']) ?? 0;
            }
            if (itemData['grams'] is String) {
              itemData['grams'] = int.tryParse(itemData['grams']) ?? 0;
            }

            final item = MartItemModel.fromJson(itemData);
            items.add(item);
            print('[MART FIRESTORE] 📡 Successfully parsed item: ${item.name}');
          } catch (e) {
            print(
                '[MART FIRESTORE] ❌ Error parsing Firestore item document ${doc.id}: $e');
            print('[MART FIRESTORE] ❌ Item data: ${doc.data()}');
          }
        }

        // Exclude the current product if specified
        if (excludeProductId != null) {
          items.removeWhere((item) => item.id == excludeProductId);
        }

        // Limit to requested amount
        final finalItems = items.take(limit).toList();

        print(
            '[MART FIRESTORE] 📡 Stream returning ${finalItems.length} products');
        print(
            '[MART FIRESTORE] 📡 Product names: ${finalItems.map((item) => item.name).toList()}');
        return finalItems;
      }).handleError((error) {
        print('[MART FIRESTORE] ❌ Stream error for all products: $error');
        return <MartItemModel>[];
      });
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error creating stream for all products: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  // ==================== SECTION-SPECIFIC PRODUCT STREAMS ====================

  /// Stream products for Product Deals section
  Stream<List<MartItemModel>> streamProductDeals({
    int limit = 10,
  }) {
    try {
      print('[MART FIRESTORE] 📡 Starting stream for Product Deals section');

      Query query = _firestore
          .collection('mart_items')
          .where('publish', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .where('isStealOfMoment', isEqualTo: true) // Trending deals
          .limit(limit);

      return query.snapshots().map((snapshot) {
        print(
            '[MART FIRESTORE] 📡 Product Deals stream: ${snapshot.docs.length} documents');
        return _parseSnapshotToMartItems(snapshot);
      }).handleError((error) {
        print('[MART FIRESTORE] ❌ Stream error for Product Deals: $error');
        return <MartItemModel>[];
      });
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error creating Product Deals stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Stream products for Hair Care section
  Stream<List<MartItemModel>> streamHairCareProducts({
    int limit = 10,
  }) {
    try {
      print('[MART FIRESTORE] 📡 Starting stream for Hair Care section');

      Query query = _firestore
          .collection('mart_items')
          .where('publish', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .where('categoryTitle', isEqualTo: 'Hair Care') // Hair care category
          .limit(limit);

      return query.snapshots().map((snapshot) {
        print(
            '[MART FIRESTORE] 📡 Hair Care stream: ${snapshot.docs.length} documents');
        return _parseSnapshotToMartItems(snapshot);
      }).handleError((error) {
        print('[MART FIRESTORE] ❌ Stream error for Hair Care: $error');
        return <MartItemModel>[];
      });
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error creating Hair Care stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Stream products for Chocolates section
  Stream<List<MartItemModel>> streamChocolateProducts({
    int limit = 10,
  }) {
    try {
      print('[MART FIRESTORE] 📡 Starting stream for Chocolates section');

      Query query = _firestore
          .collection('mart_items')
          .where('publish', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .where('categoryTitle',
              isEqualTo: 'Chocolates') // Chocolates category
          .limit(limit);

      return query.snapshots().map((snapshot) {
        print(
            '[MART FIRESTORE] 📡 Chocolates stream: ${snapshot.docs.length} documents');
        return _parseSnapshotToMartItems(snapshot);
      }).handleError((error) {
        print('[MART FIRESTORE] ❌ Stream error for Chocolates: $error');
        return <MartItemModel>[];
      });
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error creating Chocolates stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Stream products for Playtime section
  Stream<List<MartItemModel>> streamPlaytimeProducts({
    int limit = 10,
  }) {
    try {
      print('[MART FIRESTORE] 📡 Starting stream for Playtime section');

      Query query = _firestore
          .collection('mart_items')
          .where('publish', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .where('isTrending', isEqualTo: true) // Trending products
          .limit(limit);

      return query.snapshots().map((snapshot) {
        print(
            '[MART FIRESTORE] 📡 Playtime stream: ${snapshot.docs.length} documents');
        return _parseSnapshotToMartItems(snapshot);
      }).handleError((error) {
        print('[MART FIRESTORE] ❌ Stream error for Playtime: $error');
        return <MartItemModel>[];
      });
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error creating Playtime stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Stream products for Baby Care section
  Stream<List<MartItemModel>> streamBabyCareProducts({
    int limit = 10,
  }) {
    try {
      print('[MART FIRESTORE] 📡 Starting stream for Baby Care section');

      Query query = _firestore
          .collection('mart_items')
          .where('publish', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .where('categoryTitle', isEqualTo: 'Baby Care') // Baby care category
          .limit(limit);

      return query.snapshots().map((snapshot) {
        print(
            '[MART FIRESTORE] 📡 Baby Care stream: ${snapshot.docs.length} documents');
        return _parseSnapshotToMartItems(snapshot);
      }).handleError((error) {
        print('[MART FIRESTORE] ❌ Stream error for Baby Care: $error');
        return <MartItemModel>[];
      });
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error creating Baby Care stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Stream products for Local Grocery section
  Stream<List<MartItemModel>> streamLocalGroceryProducts({
    int limit = 10,
  }) {
    try {
      print('[MART FIRESTORE] 📡 Starting stream for Local Grocery section');

      Query query = _firestore
          .collection('mart_items')
          .where('publish', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .where('categoryTitle',
              isEqualTo: 'Local Grocery') // Local grocery category
          .limit(limit);

      return query.snapshots().map((snapshot) {
        print(
            '[MART FIRESTORE] 📡 Local Grocery stream: ${snapshot.docs.length} documents');
        return _parseSnapshotToMartItems(snapshot);
      }).handleError((error) {
        print('[MART FIRESTORE] ❌ Stream error for Local Grocery: $error');
        return <MartItemModel>[];
      });
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error creating Local Grocery stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Helper method to parse Firestore snapshot to MartItemModel list
  List<MartItemModel> _parseSnapshotToMartItems(QuerySnapshot snapshot) {
    if (snapshot.docs.isEmpty) {
      return <MartItemModel>[];
    }

    return snapshot.docs
        .map((doc) {
          try {
            final itemData = doc.data() as Map<String, dynamic>;
            itemData['id'] = doc.id;

            // Handle numeric fields that might be strings
            if (itemData['reviewCount'] is String) {
              itemData['reviewCount'] =
                  int.tryParse(itemData['reviewCount']) ?? 0;
            }
            if (itemData['reviewSum'] is String) {
              itemData['reviewSum'] = int.tryParse(itemData['reviewSum']) ?? 0;
            }
            if (itemData['price'] is String) {
              itemData['price'] = double.tryParse(itemData['price']) ?? 0.0;
            }
            if (itemData['disPrice'] is String) {
              itemData['disPrice'] =
                  double.tryParse(itemData['disPrice']) ?? 0.0;
            }
            if (itemData['calories'] is String) {
              itemData['calories'] = int.tryParse(itemData['calories']) ?? 0;
            }
            if (itemData['proteins'] is String) {
              itemData['proteins'] = int.tryParse(itemData['proteins']) ?? 0;
            }
            if (itemData['fats'] is String) {
              itemData['fats'] = int.tryParse(itemData['fats']) ?? 0;
            }
            if (itemData['grams'] is String) {
              itemData['grams'] = int.tryParse(itemData['grams']) ?? 0;
            }

            return MartItemModel.fromJson(itemData);
          } catch (e) {
            print('[MART FIRESTORE] ❌ Error parsing document ${doc.id}: $e');
            return null;
          }
        })
        .whereType<MartItemModel>()
        .toList();
  }

  // ==================== BANNER METHODS ====================

  /// Stream banners by position (top, middle, bottom)
  Stream<List<MartBannerModel>> streamBannersByPosition(String position,
      {int limit = 10}) {
    try {
      print('DEBUG: Streaming banners for position: $position');

      return FirebaseFirestore.instance
          .collection('mart_banners')
          .where('is_publish', isEqualTo: true)
          .where('position', isEqualTo: position)
          .orderBy('set_order')
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        print(
            'DEBUG: Banner snapshot received with ${snapshot.docs.length} documents');

        final banners = <MartBannerModel>[];
        for (var doc in snapshot.docs) {
          try {
            final banner = MartBannerModel.fromMap(doc.data(), doc.id);
            banners.add(banner);
            print(
                'DEBUG: Added banner: ${banner.title} (order: ${banner.setOrder})');
          } catch (e) {
            print('ERROR: Failed to parse banner document ${doc.id}: $e');
          }
        }

        print(
            'DEBUG: Returning ${banners.length} banners for position: $position');
        return banners;
      });
    } catch (e) {
      print('ERROR: Failed to stream banners for position $position: $e');
      return Stream.value([]);
    }
  }

  /// Stream all published banners
  Stream<List<MartBannerModel>> streamAllBanners({int limit = 20}) {
    try {
      print('DEBUG: Streaming all published banners');

      return FirebaseFirestore.instance
          .collection('mart_banners')
          .where('is_publish', isEqualTo: true)
          .orderBy('position')
          .orderBy('set_order')
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        print(
            'DEBUG: All banners snapshot received with ${snapshot.docs.length} documents');

        final banners = <MartBannerModel>[];
        for (var doc in snapshot.docs) {
          try {
            final banner = MartBannerModel.fromMap(doc.data(), doc.id);
            banners.add(banner);
            print(
                'DEBUG: Added banner: ${banner.title} (position: ${banner.position}, order: ${banner.setOrder})');
          } catch (e) {
            print('ERROR: Failed to parse banner document ${doc.id}: $e');
          }
        }

        print('DEBUG: Returning ${banners.length} total banners');
        return banners;
      });
    } catch (e) {
      print('ERROR: Failed to stream all banners: $e');
      return Stream.value([]);
    }
  }

  /// Get banners by position (one-time fetch)
  Future<List<MartBannerModel>> getBannersByPosition(String position,
      {int limit = 10}) async {
    try {
      print('DEBUG: Fetching banners for position: $position');

      final snapshot = await FirebaseFirestore.instance
          .collection('mart_banners')
          .where('is_publish', isEqualTo: true)
          .where('position', isEqualTo: position)
          .orderBy('set_order')
          .limit(limit)
          .get();

      print(
          'DEBUG: Banner fetch completed with ${snapshot.docs.length} documents');

      final banners = <MartBannerModel>[];
      for (var doc in snapshot.docs) {
        try {
          final banner = MartBannerModel.fromMap(doc.data(), doc.id);
          banners.add(banner);
          print(
              'DEBUG: Added banner: ${banner.title} (order: ${banner.setOrder})');
        } catch (e) {
          print('ERROR: Failed to parse banner document ${doc.id}: $e');
        }
      }

      print(
          'DEBUG: Returning ${banners.length} banners for position: $position');
      return banners;
    } catch (e) {
      print('ERROR: Failed to fetch banners for position $position: $e');
      return [];
    }
  }

  /// Stream items by brand ID
  Stream<List<MartItemModel>> streamItemsByBrand(String brandID) {
    try {
      print('[MART FIRESTORE] 🔍 Streaming items for brand: $brandID');

      return _firestore
          .collection(_collectionName)
          .where('brandID', isEqualTo: brandID)
          .where('isAvailable', isEqualTo: true)
          .where('publish', isEqualTo: true)
          .snapshots()
          .map((snapshot) {
        print(
            '[MART FIRESTORE] 📦 Brand items snapshot received with ${snapshot.docs.length} documents');

        final items = <MartItemModel>[];
        for (var doc in snapshot.docs) {
          try {
            final data = doc.data();
            if (data == null) continue;

            // Ensure data is a Map<String, dynamic>
            if (data is! Map<String, dynamic>) {
              print(
                  '[MART FIRESTORE] ⚠️ Document data is not a Map for ${doc.id}, type: ${data.runtimeType}');
              continue;
            }

            final Map<String, dynamic> itemData =
                Map<String, dynamic>.from(data);

            // Add document ID to the data
            itemData['id'] = doc.id;

            // Handle array fields that might be null
            if (itemData['addOnsPrice'] == null) itemData['addOnsPrice'] = [];
            if (itemData['addOnsTitle'] == null) itemData['addOnsTitle'] = [];
            if (itemData['options'] == null) itemData['options'] = [];
            if (itemData['photos'] == null) itemData['photos'] = [];
            if (itemData['review_attributes'] == null)
              itemData['review_attributes'] = [];
            if (itemData['subcategoryID'] == null)
              itemData['subcategoryID'] = [];

            // Handle numeric fields that might be strings
            if (itemData['reviewCount'] is String) {
              itemData['reviewCount'] =
                  int.tryParse(itemData['reviewCount']) ?? 0;
            }
            if (itemData['reviewSum'] is String) {
              itemData['reviewSum'] =
                  double.tryParse(itemData['reviewSum']) ?? 0.0;
            }

            final item = MartItemModel.fromJson(itemData);
            items.add(item);
            print('[MART FIRESTORE] ✅ Added brand item: ${item.name}');
          } catch (e) {
            print(
                '[MART FIRESTORE] ❌ Error parsing brand item document ${doc.id}: $e');
          }
        }

        print(
            '[MART FIRESTORE] 📦 Returning ${items.length} items for brand: $brandID');
        return items;
      });
    } catch (e) {
      print('[MART FIRESTORE] ❌ Error streaming items by brand: $e');
      return Stream.value([]);
    }
  }

  Future<Map<String, dynamic>> getHomepageSubcategoriesPaginated({
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('mart_subcategories')
          .where('show_in_homepage', isEqualTo: true)
          .where('publish', isEqualTo: true)
          .orderBy('subcategory_order', descending: false)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      final subcategories = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MartSubcategoryModel.fromJson(data);
      }).toList();

      return {
        'subcategories': subcategories,
        'lastDocument':
            querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null,
      };
    } catch (e) {
      print('[MART FIRESTORE] ❌ Paginated query error: $e');
      return {'subcategories': [], 'lastDocument': null};
    }
  }
}
