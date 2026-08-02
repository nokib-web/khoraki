class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String households = 'households';
  static const String meals = 'meals';
  static const String bazars = 'bazars';
  static const String expenses = 'expenses';

  static String user(String uid) => 'users/$uid';
  static String household(String id) => 'households/$id';
}
