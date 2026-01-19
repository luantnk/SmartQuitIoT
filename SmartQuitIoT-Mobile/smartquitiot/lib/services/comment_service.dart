import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../core/errors/exception.dart';
import '../models/post_comment.dart';
import '../models/response/error_response.dart';

class CommentService {
  static final String _apiBaseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  static final String _baseUrl = '$_apiBaseUrl/posts';

  /// Create comment for a post
  /// POST /api/posts/{postId}/comments
  Future<PostComment> createComment({
    required String accessToken,
    required int postId,
    required Map<String, dynamic> commentData,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/$postId/comments');
      print('📝 [CommentService] Creating comment...');
      print('🌐 [CommentService] URL: $url');
      
      // Detailed parentId check
      if (commentData.containsKey('parentId')) {
        print('💬 [CommentService] REPLY DETECTED - parentId in data: ${commentData['parentId']}');
      } else {
        print('📌 [CommentService] ROOT COMMENT - no parentId in data');
      }
      
      final requestBodyJson = jsonEncode(commentData);
      print('📦 [CommentService] Request Body (JSON): $requestBodyJson');
      print('🔍 [CommentService] Checking if "parentId" exists in JSON string...');
      if (requestBodyJson.contains('parentId')) {
        print('✅ [CommentService] "parentId" FOUND in JSON request body');
      } else {
        print('❌ [CommentService] "parentId" NOT FOUND in JSON request body!');
      }
      print('🔑 [CommentService] Token: ${accessToken.substring(0, 20)}...');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: requestBodyJson,
      );

      print('📊 [CommentService] Response Status: ${response.statusCode}');
      print('📦 [CommentService] Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          print('✅ [CommentService] Parsing comment data...');
          return PostComment.fromJson(data);
        } catch (parseError, stack) {
          print('❌ [CommentService] JSON Parsing Error: $parseError');
          print('🧩 [CommentService] Stack Trace: $stack');
          print('📄 [CommentService] Raw Response: ${response.body}');
          throw PostException('Failed to parse comment: $parseError');
        }
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final errorResponse = ErrorResponse.fromJson(errorData);
          print('❌ [CommentService] Server Error: ${errorResponse.message}');
          throw PostException(errorResponse.message);
        } catch (e) {
          print('❌ [CommentService] Error Response: ${response.body}');
          throw PostException('Server error: ${response.statusCode}');
        }
      }
    } on SocketException catch (e) {
      print('🚫 [CommentService] SocketException: ${e.message}');
      throw PostException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      print('🚨 [CommentService] ClientException: ${e.message}');
      throw PostException('Client error: ${e.message}');
    } on FormatException catch (e) {
      print('⚠️ [CommentService] FormatException: ${e.message}');
      throw PostException('Invalid format: ${e.message}');
    } catch (e, stack) {
      print('🔥 [CommentService] Unexpected Error: $e');
      print('🧩 [CommentService] Stack Trace: $stack');
      if (e is PostException) rethrow;
      throw PostException('Failed to create comment: $e');
    }
  }

  /// Update comment
  /// PUT /api/posts/comments/{commentId}
  Future<PostComment> updateComment({
    required String accessToken,
    required int commentId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/comments/$commentId');
      print('✏️ [CommentService] Updating comment...');
      print('🌐 [CommentService] URL: $url');
      print('📦 [CommentService] Request Body: ${jsonEncode(updateData)}');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updateData),
      );

      print('📊 [CommentService] Response Status: ${response.statusCode}');
      print('📦 [CommentService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          print('✅ [CommentService] Comment updated successfully');
          return PostComment.fromJson(data);
        } catch (parseError, stack) {
          print('❌ [CommentService] JSON Parsing Error: $parseError');
          print('🧩 [CommentService] Stack Trace: $stack');
          throw PostException('Failed to parse updated comment: $parseError');
        }
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final errorResponse = ErrorResponse.fromJson(errorData);
          print('❌ [CommentService] Server Error: ${errorResponse.message}');
          throw PostException(errorResponse.message);
        } catch (e) {
          print('❌ [CommentService] Error Response: ${response.body}');
          throw PostException('Server error: ${response.statusCode}');
        }
      }
    } on SocketException catch (e) {
      print('🚫 [CommentService] SocketException: ${e.message}');
      throw PostException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      print('🚨 [CommentService] ClientException: ${e.message}');
      throw PostException('Client error: ${e.message}');
    } catch (e, stack) {
      print('🔥 [CommentService] Unexpected Error: $e');
      print('🧩 [CommentService] Stack Trace: $stack');
      if (e is PostException) rethrow;
      throw PostException('Failed to update comment: $e');
    }
  }

  /// Delete comment
  /// DELETE /api/posts/comments/{commentId}
  Future<void> deleteComment({
    required String accessToken,
    required int commentId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/comments/$commentId');
      print('🗑️ [CommentService] Deleting comment...');
      print('🌐 [CommentService] URL: $url');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📊 [CommentService] Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ [CommentService] Comment deleted successfully');
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final errorResponse = ErrorResponse.fromJson(errorData);
          print('❌ [CommentService] Server Error: ${errorResponse.message}');
          throw PostException(errorResponse.message);
        } catch (e) {
          print('❌ [CommentService] Error Response: ${response.body}');
          throw PostException('Server error: ${response.statusCode}');
        }
      }
    } on SocketException catch (e) {
      print('🚫 [CommentService] SocketException: ${e.message}');
      throw PostException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      print('🚨 [CommentService] ClientException: ${e.message}');
      throw PostException('Client error: ${e.message}');
    } catch (e, stack) {
      print('🔥 [CommentService] Unexpected Error: $e');
      print('🧩 [CommentService] Stack Trace: $stack');
      if (e is PostException) rethrow;
      throw PostException('Failed to delete comment: $e');
    }
  }
}
