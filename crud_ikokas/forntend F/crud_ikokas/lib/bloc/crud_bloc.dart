import 'package:bloc/bloc.dart';
import 'package:crud_ikokas/bloc/crud_event.dart';
import 'package:crud_ikokas/bloc/crud_state.dart';
import 'package:crud_ikokas/repo/api_Repo.dart';

class CrudBloc extends Bloc<CrudEvent, CrudState> {
  CrudBloc() : super(CrudInitialState()) {
    on<loadCrud>((event, emit) async {
      emit(CrudloadingState());
      try {
        final items = await ApiRepo().getitem();
        emit(CrudLoadedState(cruds: items));
      } catch (e) {
        emit(CrudErrorState(error: e.toString()));
      }
    });

    on<createCrud>((event, emit) async {
      try {
        await ApiRepo().createItems(event.crud);
        final items = await ApiRepo().getitem();
        emit(CrudLoadedState(cruds: items));
      } catch (e) {
        emit(CrudErrorState(error: e.toString()));
      }
    });

    on<deleteCrud>((event, emit) async {
      try {
        await ApiRepo().deleteItems(event.id);
        final items = await ApiRepo().getitem();
        emit(CrudLoadedState(cruds: items));
      } catch (e) {
        emit(CrudErrorState(error: e.toString()));
      }
    });

    on<updateCrud>((event, emit) async {
      try {
        await ApiRepo().updateItems(event.id, event.crud);
        final items = await ApiRepo().getitem();
        emit(CrudLoadedState(cruds: items));
      } catch (e) {
        emit(CrudErrorState(error: e.toString()));
      }
    });
  }
}
