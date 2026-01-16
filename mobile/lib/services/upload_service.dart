import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // Import XFile
import 'package:flutter/foundation.dart'; // Import kIsWeb (optional if needed context, but mainly for logic)

import '../utils/constants.dart';
import 'storage_service.dart';

class UploadService {
  
  // POST /api/upload/image
  static Future<Map<String, dynamic>> uploadImage(XFile imageFile) async {
    final baseUrl = AppConstants.baseUrl;
    if (baseUrl.isEmpty) {
       return {
        'success': false,
        'message': 'Base URL is empty. Check AppConfig.',
       };
    }

    final uri = Uri.parse('$baseUrl/upload/image');
    
    // Create Multipart Request
    final request = http.MultipartRequest('POST', uri);
    
    // Add Headers (Authorization)
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add File
    // Detect mime type using name (safer for Web)
    String filename = imageFile.name;
    if (filename.isEmpty) {
      if (!kIsWeb) {
        filename = imageFile.path.split(Platform.pathSeparator).last;
      } else {
        filename = 'image.jpg'; // Fallback for Web if name missing
      }
    }
    
    String extension = filename.split('.').last.toLowerCase();
    
    MediaType contentType = MediaType('image', 'jpeg'); // Default
    
    if (extension == 'png') {
       contentType = MediaType('image', 'png');
    } else if (extension == 'jpg' || extension == 'jpeg') {
       contentType = MediaType('image', 'jpeg');
    }
    
    debugPrint("📤 Uploading: $filename, Type: $contentType, Size: ${await imageFile.length()} bytes");

    try {
      // Use bytes instead of path for cross-platform support (Web & Mobile)
      final bytes = await imageFile.readAsBytes();
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // Field name expected by backend
          bytes,
          filename: filename, // Use robust filename
          contentType: contentType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'url': data['data']['url'], // The uploaded file URL
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Upload failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode} ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }
}
