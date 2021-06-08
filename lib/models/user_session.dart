import 'package:flutter/material.dart';

class UserSession with ChangeNotifier {
  UserSessionType _selectedUserSessionType = UserSessionType.offline;
  UserSessionType get selectedUserSessionType => _selectedUserSessionType;

  set selectedUserSessionType(UserSessionType sessionType) {
    switch (sessionType) {
      case UserSessionType.offline:
        _selectedUserSessionType = sessionType;
        break;
      case UserSessionType.online:
        _selectedUserSessionType = UserSessionType.waiting;
        break;
      case UserSessionType.waiting:
        _selectedUserSessionType = sessionType;
        break;
      case UserSessionType.delivering:
        Future.delayed(const Duration(seconds: 2), () {
          _selectedUserSessionType = sessionType;
        });
        break;
      case UserSessionType.returning:
        _selectedUserSessionType = sessionType;
        break;
    }
    notifyListeners();
  }

  int get selectedUserSessionTypeIndex => _selectedUserSessionType.index;
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
    UserSessionType.waiting: 'Suche Fahrten...',
    UserSessionType.delivering: 'In Zustellung',
    UserSessionType.returning: 'Rückfahrt',
  };

  String? get title => titles[this];
}
