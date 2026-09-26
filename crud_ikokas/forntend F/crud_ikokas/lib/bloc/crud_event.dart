import 'package:crud_ikokas/model/crud_model.dart';

abstract class CrudEvent {}

class loadCrud extends CrudEvent {}

class createCrud extends CrudEvent{
  final CrudModel crud;
  createCrud({required this.crud});
}

class deleteCrud extends CrudEvent {
  final String id;
  deleteCrud({required this.id});
}

class updateCrud extends CrudEvent {
  final String id;
  final CrudModel crud;
  updateCrud({required this.id, required this.crud});
}
