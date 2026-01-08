import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

final apiClientProvider = Provider((ref) => ApiClient());

class ApiClient {
  // Use 10.0.2.2 for Android Emulator, or your LAN IP for real device
  // Update this IP to your machine's IP if running on real device
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }
  
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ));
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Future<Map<String, dynamic>> segmentImage(File imageFile) async {
    try {
      final mimeType = lookupMimeType(imageFile.path);
      final mediaType = mimeType != null ? MediaType.parse(mimeType) : null;
      
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          contentType: mediaType,
        ),
      });

      final response = await _dio.post('/segment', data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to segment image: $e');
    }
  }

  Future<Map<String, dynamic>> generateVideo({
    required File personImage, 
    required String maskUrl,
    required String personId,
  }) async {
    try {
        // Mock request, we just hit the endpoint
       final response = await _dio.post('/generate-video', data: {
           "person_id": personId,
           // actually sending files would be heavy, MVP just triggers mock
       });
       return response.data;
    } catch (e) {
       throw Exception('Failed to generate video: $e');
    }
  }
}
