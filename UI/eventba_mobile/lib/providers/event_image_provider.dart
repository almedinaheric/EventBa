import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/image/image_model.dart';
import 'base_provider.dart';

class EventImageProvider extends BaseProvider<ImageModel> {
  EventImageProvider() : super("Image");

  @override
  ImageModel fromJson(data) {
    return ImageModel.fromJson(data);
  }

  Future<List<ImageModel>> getImagesForEvent(String eventId) async {
    var url = "${baseUrl}Image/event/$eventId";

    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      List<ImageModel> images = [];
      for (var item in data) {
        images.add(fromJson(item));
      }
      return images;
    } else {
      throw Exception("Unknown error in a GET request");
    }
  }
}
