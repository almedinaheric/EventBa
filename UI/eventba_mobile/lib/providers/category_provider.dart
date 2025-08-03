import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category/category_model.dart';
import 'base_provider.dart';

class CategoryProvider extends BaseProvider<CategoryModel> {
  CategoryProvider() : super("Category");

  @override
  CategoryModel fromJson(data) {
    return CategoryModel.fromJson(data);
  }

  Future<int> getForReport({dynamic filter}) async {
    var url = "${baseUrl}Category/getForReport";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var result = int.parse(response.body);
      return result;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }
}
