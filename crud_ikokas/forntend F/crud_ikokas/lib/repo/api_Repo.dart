import 'package:crud_ikokas/model/crud_model.dart';
import 'package:dio/dio.dart';

class ApiRepo {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.22.115.23:6000'));

  Future<List<CrudModel>> getitem() async {
    try {
      Response response = await _dio.get('/ikokas');
    return (response.data as List).map((e) => CrudModel.fromJson(e)).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<void> createItems(CrudModel item) async {
    try {
      await _dio.post('/ikokas', data: item.toJson());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateItems(String id, CrudModel items) async {
    try {
      await _dio.put('/ikokas/$id', data: items.toJson());
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteItems(String id) async {
    try {
      await _dio.delete('/ikokas/$id');
    } catch (e) {
      print(e.toString());
    }
  }
}
