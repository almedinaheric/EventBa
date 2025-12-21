import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_question/user_question.dart';
import 'base_provider.dart';

class UserQuestionProvider extends BaseProvider<UserQuestion> {
  UserQuestionProvider() : super("UserQuestion");

  @override
  UserQuestion fromJson(data) {
    return UserQuestion.fromJson(data);
  }

  Future<List<UserQuestion>> getMyQuestions({dynamic filter}) async {
    var url = "${baseUrl}UserQuestion/my-questions";

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
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<List<UserQuestion>> getQuestionsForMe({dynamic filter}) async {
    var url = "${baseUrl}UserQuestion/questions-for-me";

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
      throw Exception("Unknown error in a GET request");
    }
  }

  Future<List<UserQuestion>> getQuestionsForEvent(String eventId) async {
    var url = "${baseUrl}UserQuestion/event/$eventId";

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
      throw Exception("Unknown error in a GET request");
    }
  }
}
