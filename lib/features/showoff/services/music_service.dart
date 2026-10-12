import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

  static Future<List<MusicModel>> searchMusic([String? query]) async {
    try {
      final hasQuery = query != null && query.trim().isNotEmpty;
      final response = await _dio.get(
        ApiUrl.searchMusic,
        queryParameters: hasQuery ? {'query': query.trim()} : null,
      );

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => MusicModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        debugPrint('=== [Flutter] Dio Error searching music: ${e.response?.statusCode} - ${e.response?.data} ===');
      } else {
        debugPrint('=== [Flutter] General Error searching music: $e ===');
      }
      return [];
    }

  }

}
