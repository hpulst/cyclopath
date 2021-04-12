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
        print('$sessionType');
        Future.delayed(
          const Duration(
            seconds: 3,
          ),
          () {
            _selectedUserSessionType = UserSessionType.waiting;
            notifyListeners();
          },
        );
        break;
      case UserSessionType.waiting:
        Future.delayed(
          const Duration(
            seconds: 2,
          ),
          () {
            _selectedUserSessionType = UserSessionType.delivering;
            notifyListeners();
          },
        );
        break;
      case UserSessionType.delivering:
        _selectedUserSessionType = sessionType;
        break;
      case UserSessionType.returning:
        _selectedUserSessionType = sessionType;
        break;
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
    UserSessionType.delivering: 'Unterwegs',
    UserSessionType.returning: 'Rückfahrt',
  };

  String? get title => titles[this];
}
