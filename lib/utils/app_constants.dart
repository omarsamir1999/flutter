// ignore_for_file: constant_identifier_names

class AppConstants {
  static const String APP_NAME = "Anon";
  static const int APP_VERSION = 1;
  static const String BASE_URL = "http://18.118.26.112:8080/api/v1/";
  static const Map<String, String> headers = {
    "Content-Type": "application/json"
  };
  static const String POPULAR_PRODUCT_URI = "product";
  static const String category_URI = "category";
  static const String SUB_category_URI = "subCategory";
  static const String LIST_ORDER = "orders";
  static const String LIST_ORDER_ADD = "listOrder/add";
  static const String REGISTER =
      "http://18.118.26.112:8080/api/v1/auth/register";
  static const String LOGIN =
      "http://18.118.26.112:8080/api/v1/auth/authenticate";
  static const String USER = "user";
  static String TOKEN = "";
  static const String CART_LIST = "cart-list";
  static const String CART_HISTORY_LIST = "cart-history-list";

  static const String PHONE = "";
  static const String NAME = "";
  static const String PASSWORD = "";
}
