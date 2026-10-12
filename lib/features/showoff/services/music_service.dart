import 'package:dio/dio.dart';
import 'package:frontend/core/constants/api_url.dart';

import '../../../core/network/dio_client.dart';

class MusicModel {
  final String id;
  final String title;
  final String artist;
  final String previewUrl;
  final String? coverImage;
  final int? duration;

  MusicModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.previewUrl,
    this.coverImage,
    this.duration,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) {
    return MusicModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
      coverImage: json['coverImage'],
      duration: json['duration'],
    );
  }
}

class MusicService {
  static final Dio _dio = DioClient.instance;

  static Future<List<MusicModel>> searchMusic(String query) async {
    try {
      print('=== [Flutter] MusicService: Searching for "$query" ===');
      if (query.trim().isEmpty) return [];

      print('=== [Flutter] API URL: ${ApiUrl.searchMusic} ===');
      final response = await _dio.get(
        ApiUrl.searchMusic,
        queryParameters: {'query': query.trim()},
      );

      print('=== [Flutter] Music Search Response Status Code: ${response.statusCode} ===');
      print('=== [Flutter] Music Search Response Data: ${response.data} ===');

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        print('=== [Flutter] Parsed ${data.length} music tracks. ===');
        return data.map((json) => MusicModel.fromJson(json)).toList();
      } else {
        print('=== [Flutter] Success flag is false or data is null ===');
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        print('=== [Flutter] Dio Error searching music: ${e.response?.statusCode} - ${e.response?.data} ===');
      } else {
        print('=== [Flutter] General Error searching music: $e ===');
      }
      return [];
    }
  }
}
