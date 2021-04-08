import 'dart:io';

import 'package:flutter/material.dart';

class UserSession with ChangeNotifier {
  UserSessionType _selectedUserSessionType = UserSessionType.offline;

  UserSessionType get selectedUserSessionType => _selectedUserSessionType;

  set selectedUserSessionType(UserSessionType sessionType) {
    _selectedUserSessionType = sessionType;
    notifyListeners();
  }
}

enum UserSessionType {
  offline,
  online,
  waiting,
  delivering,
  returning,
}

extension UserSessionTypeExtension on UserSessionType {
  static const titles = {
    UserSessionType.offline: 'Du bist offline',
    UserSessionType.online: 'Du bist online',
    UserSessionType.waiting: 'Suche Fahrten',
    UserSessionType.delivering: '',
    UserSessionType.returning: '',
  };

  String? get title => titles[this];
}


  // final cat = Cat.white;
  // print('cat name: ${cat.name}');