import 'package:crud_ikokas/model/crud_model.dart';

abstract class CrudState {}

class CrudInitialState extends CrudState {}

class CrudloadingState extends CrudState {}

class CrudLoadedState extends CrudState {
  final List<CrudModel> cruds;

  CrudLoadedState({required this.cruds});
}

class CrudErrorState extends CrudState {
  final String error;

  CrudErrorState({required this.error});
}
