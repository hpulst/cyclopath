import 'dart:io';

import 'package:flutter/cupertino.dart';

class UserSession with ChangeNotifier {
  UserSessionType _selectedUserSessionType = UserSessionType.offline;

  UserSessionType get selectedUserSessionType => _selectedUserSessionType;

  set selectedUserSessionType(UserSessionType sessionType) {
    _selectedUserSessionType = sessionType;
    if (sessionType == UserSessionType.online) {
      Future.delayed(
          const Duration(
            milliseconds: 1500,
          ), () {
        _selectedUserSessionType = UserSessionType.waiting;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  int get selectedUserSessionTypeIndex => _selectedUserSessionType.index;
}

// enum UserSessionDrag {
//   WaitingSheet(),
//   OfflineSheet(),
// }

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
