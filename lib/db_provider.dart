import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/product.dart';

class DBProvider {
  Database database;

  Future<bool> initDB() async {
    try {
      final String databaseName = "TODOLIST.db";
      final String databasePath = await getDatabasesPath();
      final String path = join(databasePath, databaseName); //join path database

      if (!await Directory(dirname(path)).exists()) { //check had database
        await Directory(dirname(path)).create(recursive: true); //no database so create database
      }

      database = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          print("Database Create");
          String sql = "CREATE TABLE $TABLE_PRODUCT ("
              "$COLUMN_ID INTEGER PRIMARY KEY,"
              "$COLUMN_TITLE TEXT,"
              "$COLUMN_DETAIL TEXT,"
              "$COLUMN_ISCHECK INTEGER" // 0 (false) and 1 (true).
              ")";
          await db.execute(sql);
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          print("Database oldVersion: $oldVersion, newVersion $newVersion");
          String sql = "CREATE TABLE SHOP ("
              "id INTEGET PRIMARY KEY,"
              "name TEXT"
              ")";
          await db.execute(sql);
        },
        onOpen: (Database db) async {
          print("Database version: ${await db.getVersion()}");
        },
      );
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future close() async => database.close();

  Future<List<Product>> getProducts() async {
    List<Map> maps = await database.query(
      TABLE_PRODUCT,
      columns: [COLUMN_ID, COLUMN_TITLE, COLUMN_DETAIL, COLUMN_ISCHECK],
    );

//    List<Map> maps = await database.rawQuery("SELECT * FROM $TABLE_PRODUCT");

    if (maps.length > 0) {
      return maps.map((p) => Product.fromMap(p)).toList();
    }
    return [];
  }

  Future<Product> getProduct(int id) async {
    List<Map> maps = await database.query(
      TABLE_PRODUCT,
      columns: [COLUMN_ID, COLUMN_TITLE, COLUMN_DETAIL, COLUMN_ISCHECK],
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );

    if (maps.length > 0) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<Product> insertProduct(Product product) async {
    product.id = await database.insert(TABLE_PRODUCT, product.toMap());
    // product.id = await database.rawInsert("INSERT Into ....");
    return product;
  }

  Future<int> updateProduct(Product product) async {
    print(product.id);
    return await database.update(
      TABLE_PRODUCT,
      product.toMap(),
      where: "$COLUMN_ID = ?",
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    return await database.delete(
      TABLE_PRODUCT,
      where: "$COLUMN_ID = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    String sql = "Delete from $TABLE_PRODUCT";
    return await database.rawDelete(sql);
  }
}
