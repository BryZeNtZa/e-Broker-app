import 'dart:developer';

class Adapter {
  ///String to int
  static int? forceInt(value) {
    if (value == null) {
      return null;
    }
    if (value == '') {
      return 0;
    }
    if (value is int) {
      return value;
    } else {
      try {
        return int.tryParse(value as String);
      } catch (e) {
        log('$value is not valid parsable int');
      }
    }
    return null;
  }

  double? forceDouble(value) {
    if (value == null) {
      return null;
    }
    if (value == '') {
      return 0;
    }
    if (value is double) {
      return value;
    } else {
      try {
        return double.tryParse(value as String);
      } catch (e) {
        rethrow;
      }
    }
  }
}
