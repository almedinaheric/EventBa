import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eventba_admin/models/user_question/user_question.dart';
import 'package:eventba_admin/providers/base_provider.dart';

class UserQuestionProvider extends BaseProvider<UserQuestion> {
  UserQuestionProvider() : super("UserQuestion");

  @override
  UserQuestion fromJson(data) {
    return UserQuestion.fromJson(data);
  }

  Future<List<UserQuestion>> getAdminQuestions() async {
    var url = "${baseUrl}UserQuestion/admin-questions";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<UserQuestion> questions = [];
      for (var item in data) {
        questions.add(fromJson(item));
      }
      return questions;
    } else {
      throw Exception("Failed to load admin questions");
    }
  }
}
