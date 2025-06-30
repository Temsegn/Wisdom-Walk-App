import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wisdomwalk/models/prayer_model.dart';

class PrayerService {
  static const String _baseUrl = 'https://wisdom-walk-app.onrender.com/api/posts';

  Future<List<PrayerModel>> getPrayers({String filter = 'all'}) async {
    final uri = Uri.parse('$_baseUrl?filter=$filter'); // Adjust this if your backend expects a different query format

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PrayerModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch prayers');
    }
  }

  Future<PrayerModel> addPrayer({
    required String type,
    required String userId,
    required String content,
    required bool isAnonymous,
    String? userName,
    String? userAvatar,
  }) async {
    final uri = Uri.parse("$_baseUrl");
    final body = json.encode({
      'type': type,
      'userId': userId,
      'content': content,
      'isAnonymous': isAnonymous,
      'userName': "Anonymouns",
      'userAvatar': "https://www.iconfinder.com/icons/1364551/avatar_monk_profile_religious_user_icon",
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return PrayerModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add prayer');
    }
  }

  Future<void> updatePrayingUsers({
    required String prayerId,
    required List<String> prayingUsers,
  }) async {
    final uri = Uri.parse('$_baseUrl/$prayerId/praying-users');

    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'prayingUsers': prayingUsers}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update praying users');
    }
  }

  Future<PrayerComment> addComment({
    required String prayerId,
    required String userId,
    required String content,
    required bool isAnonymous,
    String? userName,
    String? userAvatar,
  }) async {
    final uri = Uri.parse('$_baseUrl/$prayerId/comments');

    final body = json.encode({
      'userId': userId,
      'content': content,
      'isAnonymous': isAnonymous,
      'userName': userName,
      'userAvatar': userAvatar,
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return PrayerComment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add comment');
    }
  }
}
