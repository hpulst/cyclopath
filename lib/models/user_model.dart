import 'package:uuid/uuid.dart';

//User = Courier

class User {
  User({
    String? id,
    this.name,
    this.userStatus = UserStatus.offline,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String? name;
  final UserStatus userStatus;
}

enum UserStatus {
  offline,
  online,
  waiting,
  delivering,
  returning,
}
