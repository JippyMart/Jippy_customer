

class MartItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? disPrice;
  final String photo;
  final List<String>? photos;
  final bool isAvailable;
  final bool publish;
  final bool veg;
  final bool nonveg;
  final int quantity;
  final String? vendorID;
  final String? categoryID;
  final double? calories;
  final double? grams;
  final double? proteins;
  final double? fats;
  final List<String>? addOnsTitle;
  final List<String>? addOnsPrice;
  final List<String>? sizeTitle;
  final List<String>? sizePrice;
  final Map<String, dynamic>? attributes;
  final List<Map<String, dynamic>>? variants;
  final String? reviewCount;
  final String? reviewSum;
  final bool? takeawayOption;
  final String? migratedBy;
  final String? createdAt;
  final String? updatedAt;
  final String? brand;
  final String? brandID;
  final String? brandTitle;
  final String? weight;
  final String? expiryDate;
  final bool? isFeatured;
  final bool? isOnSale;
  final double? discountPercentage;
  final String? barcode;
  final List<String>? tags;
  final Map<String, dynamic>? nutritionalInfo;
  final List<String>? allergens;
  final bool? isOrganic;
  final bool? isGlutenFree;
  final dynamic subcategoryID; // Can be String or List<String>
  final bool? isBestSeller;
  final bool? isFeature;
  final bool? isNew;
  final bool? isTrending;
  final bool? isSeasonal;
  final bool? isSpotlight;
  final bool? isStealOfMoment;
  final bool? has_options;
  final int? options_count;
  final List<Map<String, dynamic>>? options;
final String? categoryTitle;
  MartItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.disPrice,
    required this.photo,
    this.photos,
    required this.isAvailable,
    required this.publish,
    required this.veg,
    required this.nonveg,
    required this.quantity,
    this.vendorID,
    this.categoryID,
    this.calories,
    this.grams,
    this.proteins,
    this.fats,
    this.addOnsTitle,
    this.addOnsPrice,
    this.sizeTitle,
    this.sizePrice,
    this.attributes,
    this.variants,
    this.reviewCount,
    this.reviewSum,
    this.takeawayOption,
    this.migratedBy,
    this.createdAt,
    this.updatedAt,
    this.brand,
    this.brandID,
    this.brandTitle,
    this.weight,  
    this.expiryDate,
    this.isFeatured,
    this.isOnSale,
    this.discountPercentage,
    this.barcode,
    this.tags,
    this.nutritionalInfo,
    this.allergens,
    this.isOrganic,
    this.isGlutenFree,
    this.subcategoryID,
    this.isBestSeller,
    this.isFeature,
    this.isNew,
    this.isTrending,
    this.isSeasonal,
    this.isSpotlight,
    this.isStealOfMoment,
    this.has_options,
    this.options_count,
    this.options,
    this.categoryTitle,
  });

  factory MartItemModel.fromJson(Map<String, dynamic> json) {
    try {
      print('[MART ITEM MODEL] Parsing JSON: ${json.keys.toList()}');
      
      double parsePrice(dynamic price) {
        if (price == null) return 0.0;
        if (price is num) return price.toDouble();
        if (price is String) {
          return double.tryParse(price) ?? 0.0;
        }
        return 0.0;
      }

      return MartItemModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: parsePrice(json['price']),
        disPrice: parsePrice(json['disPrice']),
        photo: json['photo']?.toString() ?? '',
        photos: json['photos'] is List ? List<String>.from(json['photos']) : null,
        isAvailable: json['isAvailable'] ?? true,
        publish: json['publish'] ?? true,
        veg: json['veg'] ?? false,
        nonveg: json['nonveg'] ?? false,
        quantity: json['quantity'] ?? 0,
        vendorID: json['vendorID']?.toString(),
        categoryID: json['categoryID']?.toString(),
          categoryTitle: json['categoryTitle']?.toString(),
        calories: (json['calories'] as num?)?.toDouble(),
        grams: (json['grams'] as num?)?.toDouble(),
        proteins: (json['proteins'] as num?)?.toDouble(),
        fats: (json['fats'] as num?)?.toDouble(),
        addOnsTitle: json['addOnsTitle'] is List ? List<String>.from(json['addOnsTitle']) : null,
        addOnsPrice: json['addOnsPrice'] is List ? List<String>.from(json['addOnsPrice']) : null,
        sizeTitle: json['sizeTitle'] is List ? List<String>.from(json['sizeTitle']) : null,
        sizePrice: json['sizePrice'] is List ? List<String>.from(json['sizePrice']) : null,
        attributes: json['attributes'] is Map ? Map<String, dynamic>.from(json['attributes']) : null,
        variants: json['variants'] is List ? List<Map<String, dynamic>>.from(json['variants']) : null,
        options: json['options'] is List ? List<Map<String, dynamic>>.from(json['options']) : null,
        reviewCount: json['reviewCount']?.toString(),
        reviewSum: json['reviewSum']?.toString(),
        takeawayOption: json['takeawayOption'],
        migratedBy: json['migratedBy']?.toString(),
        createdAt: json['createdAt']?.toString(),
        updatedAt: json['updatedAt']?.toString(),
        brand: json['brand']?.toString(),
        brandID: json['brandID']?.toString(),
        brandTitle: json['brandTitle']?.toString(),
        weight: json['weight']?.toString(),
        expiryDate: json['expiryDate']?.toString(),
        isFeatured: json['isFeatured'],
        isOnSale: json['isOnSale'],
        discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
        barcode: json['barcode']?.toString(),
        tags: json['tags'] is List ? List<String>.from(json['tags']) : null,
        nutritionalInfo: json['nutritionalInfo'] is Map ? Map<String, dynamic>.from(json['nutritionalInfo']) : null,
        allergens: json['allergens'] is List ? List<String>.from(json['allergens']) : null,
        isOrganic: json['isOrganic'],
        isGlutenFree: json['isGlutenFree'],
        subcategoryID: json['subcategoryID'],
        isBestSeller: json['isBestSeller'],
        isFeature: json['isFeature'],
        isNew: json['isNew'],
        isTrending: json['isTrending'],
        isSeasonal: json['isSeasonal'],
        isSpotlight: json['isSpotlight'],
        isStealOfMoment: json['isStealOfMoment'],
        has_options: json['has_options'],
        options_count: json['options_count'],
      );
    } catch (e, stackTrace) {
      print('[MART ITEM MODEL] Error parsing JSON: $e');
      print('[MART ITEM MODEL] Stack trace: $stackTrace');
      print('[MART ITEM MODEL] JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'disPrice': disPrice,
      'photo': photo,
      'photos': photos,
      'isAvailable': isAvailable,
      'publish': publish,
      'veg': veg,
      'nonveg': nonveg,
      'quantity': quantity,
      'vendorID': vendorID,
      'categoryID': categoryID,
      'calories': calories,
      'grams': grams,
      'proteins': proteins,
      'fats': fats,
      'addOnsTitle': addOnsTitle,
      'addOnsPrice': addOnsPrice,
      'sizeTitle': sizeTitle,
      'sizePrice': sizePrice,
      'attributes': attributes,
      'variants': variants,
      'options': options,
      'reviewCount': reviewCount,
      'reviewSum': reviewSum,
      'takeawayOption': takeawayOption,
      'migratedBy': migratedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'brand': brand,
      'brandID': brandID,
      'brandTitle': brandTitle,
      'weight': weight,
      'expiryDate': expiryDate,
      'isFeatured': isFeatured,
      'isOnSale': isOnSale,
      'discountPercentage': discountPercentage,
      'barcode': barcode,
      'tags': tags,
      'nutritionalInfo': nutritionalInfo,
      'allergens': allergens,
      'isOrganic': isOrganic,
      'isGlutenFree': isGlutenFree,
      'subcategoryID': subcategoryID,
      'isBestSeller': isBestSeller,
      'isFeature': isFeature,
      'isNew': isNew,
      'isTrending': isTrending,
      'isSeasonal': isSeasonal,
      'isSpotlight': isSpotlight,
      'isStealOfMoment': isStealOfMoment,
      'has_options': has_options,
      'options_count': options_count,
      'categoryTitle': categoryTitle,
    };
  }

  // Getters for compatibility
  bool get isFeaturedItem => isFeatured ?? false;
  bool get isOnSaleItem => isOnSale ?? false;
  
  // Helper methods
  double get finalPrice => disPrice ?? price;
  bool get hasDiscount => disPrice != null && disPrice! < price;
  double get discountPercent => hasDiscount ? ((price - disPrice!) / price * 100) : 0.0;
  bool get isOutOfStock => quantity <= 0;
  bool get canOrder => isAvailable && !isOutOfStock;
  bool get canAddToCart => canOrder;

  // Legacy compatibility getters
  String get displayName => name;
  String get displayDescription => description;
  String get mainImage => photo;
  double get currentPrice => finalPrice;
  double get originalPrice => price;
  double get calculatedDiscountPercentage => discountPercent;
  bool get isPublished => publish;
  bool get isAvailableForPurchase => isAvailable && isPublished;
  bool get isVegetarian => veg;
  bool get isNonVegetarian => nonveg;
  bool get hasUnlimitedStock => quantity == -1;
  
  String get stockStatus {
    if (hasUnlimitedStock) return 'In Stock';
    if (isOutOfStock) return 'Out of Stock';
    if (quantity > 0) return 'Limited Stock';
    return 'Out of Stock';
  }
  
  double get averageRating {
    if (reviewSum == null || reviewSum!.isEmpty || reviewCount == null || reviewCount!.isEmpty) return 0.0;
    try {
      final sum = double.parse(reviewSum!);
      final count = int.parse(reviewCount!);
      if (count == 0) return 0.0;
      return sum / count;
    } catch (e) {
      return 0.0;
    }
  }
  
  int get totalReviews {
    if (reviewCount == null || reviewCount!.isEmpty) return 0;
    try {
      return int.parse(reviewCount!);
    } catch (e) {
      return 0;
    }
  }
  
  String get nutritionalSummary {
    List<String> info = [];
    if (calories != null) info.add('${calories} cal');
    if (proteins != null) info.add('${proteins}g protein');
    if (fats != null) info.add('${fats}g fat');
    if (grams != null) info.add('${grams}g');
    return info.join(' • ');
  }
  
  String get dietaryInfo {
    List<String> info = [];
    if (isVegetarian) info.add('Vegetarian');
    if (isOrganic == true) info.add('Organic');
    if (isGlutenFree == true) info.add('Gluten Free');
    return info.join(', ');
  }
  
  List<String> get allImages => [photo, ...?photos];
}
