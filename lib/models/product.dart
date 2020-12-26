const String TABLE_PRODUCT = 'product';
const String COLUMN_ID = 'id';
const String COLUMN_TITLE = 'title';
const String COLUMN_DETAIL = 'detail';
const String COLUMN_ISCHECK = 'ischeck';

class Product {
  int id;
  String title;
  String detail;
  int ischeck;

  Product();

  // insert product to database
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      COLUMN_TITLE: title,
      COLUMN_DETAIL: detail,
      COLUMN_ISCHECK: ischeck,
    };

    if (id != null) {
      map[COLUMN_ID] = id;
    }
    return map;
  }

  // select product from database
  Product.fromMap(Map<String, dynamic> map) {
    id = map[COLUMN_ID];
    title = map[COLUMN_TITLE];
    detail = map[COLUMN_DETAIL];
    ischeck = map[COLUMN_ISCHECK];
  }

  @override
  String toString() => "$id, $title, $detail, $ischeck";
}
