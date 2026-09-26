import 'package:realm/realm.dart';

part 'user_model.realm.dart';

@RealmModel()
class _UserModel {
  @PrimaryKey()
  late String uid;
  late String name;
  late String email;
  late String password;
  bool isLoggedIn = true;
  String? location;
  bool isAdmin = false;
}
