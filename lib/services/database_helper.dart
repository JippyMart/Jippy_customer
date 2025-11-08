
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cart.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // ✅ Bumped version (important!)
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE cart_products ADD COLUMN vendorName TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE cart_products ADD COLUMN promo_id TEXT NULL');
        }
        if (oldVersion < 4) {
          // ✅ Change vendorName to nullable
          await db.execute('ALTER TABLE cart_products RENAME TO cart_products_old');

          await _createDB(db, newVersion);

          await db.execute('''
            INSERT INTO cart_products (id, category_id, name, photo, price, discountPrice, vendorID, vendorName, quantity, extras_price, extras, variant_info, promo_id)
            SELECT id, category_id, name, photo, price, discountPrice, vendorID, vendorName, quantity, extras_price, extras, variant_info, promo_id
            FROM cart_products_old
          ''');

          await db.execute('DROP TABLE cart_products_old');
        }
      },
    );

  }

  Future _createDB(Database db, int version) async {
    // ✅ Changed schema: vendorName is now nullable
    const textType = 'TEXT'; // previously 'TEXT NOT NULL'
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE cart_products (
      id $textType,
      category_id $textType,
      name $textType,
      photo $textType,
      price $textType,
      discountPrice $textType,
      vendorID $textType,
      vendorName $textType,       -- ✅ now nullable
      quantity $intType,
      extras_price $textType,
      extras $textType,
      variant_info $textType NULL,
      promo_id TEXT NULL
    )
    ''');

    if (kDebugMode) {
      print('✅ Table cart_products created (version $version)');
    }

  }
//changes
  Future<void> insertCartProduct(CartProductModel product) async {
    final db = await instance.database;
    // ✅ Ensure non-null vendorName to avoid errors
    final data = product.toJson()
      ..['variant_info'] = jsonEncode(product.variantInfo)
      ..['extras'] = jsonEncode(product.extras)
      ..['vendorName'] = product.vendorName ?? 'Unknown Vendor';
    if (kDebugMode) log('🛒 insertCartProduct -> $data');
    await db.insert(
      'cart_products',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

  }
  Future<List<CartProductModel>> fetchCartProducts() async {
    final db = await instance.database;
    final maps = await db.query('cart_products');
    if (kDebugMode) {
      print('DEBUG: DatabaseHelper - Found ${maps.length} cart products');
    }
    return List.generate(maps.length, (i) {
      return CartProductModel.fromJson(maps[i]);
    });

  }

  Future<void> updateCartProduct(CartProductModel product) async {
    final db = await instance.database;

    final data = product.toJson()
      ..['variant_info'] = jsonEncode(product.variantInfo)
      ..['extras'] = jsonEncode(product.extras)
      ..['vendorName'] = product.vendorName ?? 'Unknown Vendor';
    if (kDebugMode) log('🛠 updateCartProduct -> $data');
    await db.update(
      'cart_products',
      data,
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteCartProduct(String id) async {
    final db = await instance.database;
    await db.delete('cart_products', where: 'id = ?', whereArgs: [id]);

  }
  Future<void> updateCartProductQuantity(String id, String quantity) async {
    final db = await instance.database;
    await db.update(
      'cart_products',
      {'quantity': int.tryParse(quantity) ?? 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllCartProducts() async {
    final db = await instance.database;
    await db.delete('cart_products');
    if (kDebugMode) print('🗑 All cart products deleted');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}



// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/foundation.dart';
//
// import 'package:customer/constant/constant.dart';
// import 'package:customer/models/cart_product_model.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._init();
//   static Database? _database;
//
//   DatabaseHelper._init();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('cart.db');
//     return _database!;
//   }
//
//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);
//
//     return await openDatabase(
//       path,
//       version: 3, // Updated version to trigger migration
//       onCreate: _createDB,
//       onUpgrade: (db, oldVersion, newVersion) async {
//         if (oldVersion < 2) {
//           await db.execute('ALTER TABLE cart_products ADD COLUMN vendorName TEXT');
//         }
//         if (oldVersion < 3) {
//           // Add promo_id column for existing databases
//           await db.execute('ALTER TABLE cart_products ADD COLUMN promo_id TEXT NULL');
//         }
//       },
//     );
//   }
//
//   Future _createDB(Database db, int version) async {
//     // const idType = 'TEXT PRIMARY KEY';
//     const textType = 'TEXT NOT NULL';
//     const intType = 'INTEGER NOT NULL';
//
//     await db.execute('''
//     CREATE TABLE cart_products (
//       id $textType,
//       category_id $textType,
//       name $textType,
//       photo $textType,
//       price $textType,
//       discountPrice $textType,
//       vendorID $textType,
//       vendorName $textType,
//       quantity $intType,
//       extras_price $textType,
//       extras $textType,
//       variant_info $textType NULL,
//       promo_id TEXT NULL
//     )
//     ''');
//     if (kDebugMode) {
//       print('Table cart_products created'); // Debugging
//     }
//   }
//
//   Future<void> insertCartProduct(CartProductModel product) async {
//     if (kDebugMode) {
//       log(product.toJson().toString());
//     }
//     final db = await instance.database;
//     await db.insert(
//       'cart_products',
//       product.toJson()
//         ..['variant_info'] = jsonEncode(product.variantInfo)
//         ..['extras'] = jsonEncode(product.extras),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }
//
//   Future<List<CartProductModel>> fetchCartProducts() async {
//     if (kDebugMode) {
//       print('DEBUG: DatabaseHelper fetchCartProducts() called');
//     }
//     final db = await instance.database;
//     final maps = await db.query('cart_products');
//     if (kDebugMode) {
//       print('DEBUG: DatabaseHelper - Found ${maps.length} cart products in database');
//     }
//     return List.generate(maps.length, (i) {
//       return CartProductModel.fromJson(maps[i]);
//     });
//   }
//
//   Future<void> updateCartProduct(CartProductModel product) async {
//     if (kDebugMode) {
//       log(product.toJson().toString());
//     }
//     final db = await instance.database;
//     await db.update(
//       'cart_products',
//       product.toJson()
//         ..['variant_info'] = jsonEncode(product.variantInfo)
//         ..['extras'] = jsonEncode(product.extras),
//       where: 'id = ?',
//       whereArgs: [product.id],
//     );
//   }
//
//   Future<void> deleteCartProduct(String id) async {
//     final db = await instance.database;
//     await db.delete(
//       'cart_products',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
//
//   Future<void> updateCartProductQuantity(String id, String quantity) async {
//     final db = await instance.database;
//     await db.update(
//       'cart_products',
//       {'quantity': int.tryParse(quantity) ?? 1},
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
//
//   Future close() async {
//     final db = await instance.database;
//     db.close();
//   }
//
//   Future<void> deleteAllCartProducts() async {
//     print('DEBUG: DatabaseHelper deleteAllCartProducts() called');
//     final db = await database;
//     cartItem.clear();
//     await db.delete('cart_products');
//     print('DEBUG: DatabaseHelper - All cart products deleted from database');
//   }
// }
