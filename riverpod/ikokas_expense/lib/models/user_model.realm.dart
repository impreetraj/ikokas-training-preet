// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class UserModel extends _UserModel
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  UserModel(
    String uid,
    String name,
    String email,
    String password, {
    bool isLoggedIn = true,
    String? location,
    bool isAdmin = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<UserModel>({
        'isLoggedIn': true,
        'isAdmin': false,
      });
    }
    RealmObjectBase.set(this, 'uid', uid);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'password', password);
    RealmObjectBase.set(this, 'isLoggedIn', isLoggedIn);
    RealmObjectBase.set(this, 'location', location);
    RealmObjectBase.set(this, 'isAdmin', isAdmin);
  }

  UserModel._();

  @override
  String get uid => RealmObjectBase.get<String>(this, 'uid') as String;
  @override
  set uid(String value) => RealmObjectBase.set(this, 'uid', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get email => RealmObjectBase.get<String>(this, 'email') as String;
  @override
  set email(String value) => RealmObjectBase.set(this, 'email', value);

  @override
  String get password =>
      RealmObjectBase.get<String>(this, 'password') as String;
  @override
  set password(String value) => RealmObjectBase.set(this, 'password', value);

  @override
  bool get isLoggedIn => RealmObjectBase.get<bool>(this, 'isLoggedIn') as bool;
  @override
  set isLoggedIn(bool value) => RealmObjectBase.set(this, 'isLoggedIn', value);

  @override
  String? get location =>
      RealmObjectBase.get<String>(this, 'location') as String?;
  @override
  set location(String? value) => RealmObjectBase.set(this, 'location', value);

  @override
  bool get isAdmin => RealmObjectBase.get<bool>(this, 'isAdmin') as bool;
  @override
  set isAdmin(bool value) => RealmObjectBase.set(this, 'isAdmin', value);

  @override
  Stream<RealmObjectChanges<UserModel>> get changes =>
      RealmObjectBase.getChanges<UserModel>(this);

  @override
  Stream<RealmObjectChanges<UserModel>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<UserModel>(this, keyPaths);

  @override
  UserModel freeze() => RealmObjectBase.freezeObject<UserModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'uid': uid.toEJson(),
      'name': name.toEJson(),
      'email': email.toEJson(),
      'password': password.toEJson(),
      'isLoggedIn': isLoggedIn.toEJson(),
      'location': location.toEJson(),
      'isAdmin': isAdmin.toEJson(),
    };
  }

  static EJsonValue _toEJson(UserModel value) => value.toEJson();
  static UserModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'uid': EJsonValue uid,
        'name': EJsonValue name,
        'email': EJsonValue email,
        'password': EJsonValue password,
      } =>
        UserModel(
          fromEJson(uid),
          fromEJson(name),
          fromEJson(email),
          fromEJson(password),
          isLoggedIn: fromEJson(ejson['isLoggedIn'], defaultValue: true),
          location: fromEJson(ejson['location']),
          isAdmin: fromEJson(ejson['isAdmin'], defaultValue: false),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(UserModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, UserModel, 'UserModel', [
      SchemaProperty('uid', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('email', RealmPropertyType.string),
      SchemaProperty('password', RealmPropertyType.string),
      SchemaProperty('isLoggedIn', RealmPropertyType.bool),
      SchemaProperty('location', RealmPropertyType.string, optional: true),
      SchemaProperty('isAdmin', RealmPropertyType.bool),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
