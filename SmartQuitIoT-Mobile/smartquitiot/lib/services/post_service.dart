import 'dart:convert';
import 'package:SmartQuitIoT/models/post_detail.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../core/errors/exception.dart';
import '../models/response/error_response.dart';
import '../models/response/post_detail_response.dart';
import '../models/response/post_like_response.dart';
import '../models/response/post_list_response.dart';
import 'dart:io'; // <-- thêm dòng này để dùng SocketException

class PostService {
  static final String _apiBaseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  static final String _baseUrl = '$_apiBaseUrl/posts';
  // static const Duration _timeout = Duration(seconds: 30);

  Future<PostListResponse> getLatestPosts({
    required String accessToken,
    int limit = 5,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/latest?limit=$limit');
      print('📡 [API] GET: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('✅ [API] Status: ${response.statusCode}');
      print('📦 [API] Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PostListResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(
          'Server returned ${response.statusCode}: ${errorResponse.message}',
        );
      }
    } on http.ClientException catch (e) {
      print('🚨 [ClientException] ${e.message}');
      print('🧩 [StackTrace]: ${StackTrace.current}');
      throw PostException('ClientException: ${e.message}');
    } on SocketException catch (e) {
      print('🚫 [SocketException] ${e.message}');
      throw PostException('SocketException: ${e.message}');
    } on FormatException catch (e) {
      print('⚠️ [FormatException] ${e.message}');
      throw PostException('Invalid response format: ${e.message}');
    } catch (e, stack) {
      print('🔥 [Unexpected Error] $e');
      print('🧩 [StackTrace]: $stack');
      throw PostException('Failed to get latest posts: ${e.toString()}');
    }
  }

  Future<PostListResponse> getAllPosts({
    required String accessToken,
    String? query,
  }) async {
    try {
      String url = _baseUrl;
      if (query != null && query.isNotEmpty) {
        url += '?query=$query';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PostListResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to get posts: ${e.toString()}');
    }
  }

  Future<PostDetailResponse> getPostDetail({
    required String accessToken,
    required int postId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PostDetailResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to get post detail: ${e.toString()}');
    }
  }

  Future<PostLikeResponse> likePost({
    required String accessToken,
    required int postId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$postId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PostLikeResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to like post: ${e.toString()}');
    }
  }

  Future<PostLikeResponse> unlikePost({
    required String accessToken,
    required int postId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$postId/like'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PostLikeResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to unlike post: ${e.toString()}');
    }
  }

  Future<PostDetailResponse> createPost({
    required String accessToken,
    required Map<String, dynamic> postData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Check if response is wrapped or direct Post object
        if (data.containsKey('data') && data.containsKey('success')) {
          // Wrapped response: { "success": true, "data": {...} }
          return PostDetailResponse.fromJson(data);
        } else {
          // Direct Post object response: { "id": 9, "title": ... }
          print('⚠️ [PostService] Direct post response detected, wrapping...');
          return PostDetailResponse.fromJson({
            'success': true,
            'message': 'Post created successfully',
            'data': data,
            'code': response.statusCode,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to create post: ${e.toString()}');
    }
  }

  Future<void> deletePost({
    required String accessToken,
    required int postId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        throw PostException(errorResponse.message);
      }
    } on http.ClientException {
      throw PostException('Network error. Please check your connection.');
    } on FormatException {
      throw PostException('Invalid response format from server.');
    } catch (e) {
      if (e is PostException) {
        rethrow;
      }
      throw PostException('Failed to delete post: ${e.toString()}');
    }
  }

  /// Get current user's posts
  /// GET /api/posts/my-posts
  Future<PostListResponse> getMyPosts({
    required String accessToken,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/my-posts');
      print('📡 [PostService] Getting my posts...');
      print('🌐 [PostService] URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📊 [PostService] Response Status: ${response.statusCode}');
      print('📦 [PostService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        print('✅ [PostService] My posts fetched successfully');
        
        // Check if response is wrapped or direct array
        if (decoded is Map<String, dynamic>) {
          // Wrapped response: { "success": true, "data": [...] }
          return PostListResponse.fromJson(decoded);
        } else if (decoded is List) {
          // Direct array response: [{...}, {...}]
          print('⚠️ [PostService] Direct array response detected, wrapping...');
          return PostListResponse.fromJson({
            'success': true,
            'message': 'My posts fetched successfully',
            'data': decoded,
            'code': 200,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        } else {
          throw PostException('Unexpected response format');
        }
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final errorResponse = ErrorResponse.fromJson(errorData);
        print('❌ [PostService] Server Error: ${errorResponse.message}');
        throw PostException(errorResponse.message);
      }
    } on SocketException catch (e) {
      print('🚫 [PostService] SocketException: ${e.message}');
      throw PostException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      print('🚨 [PostService] ClientException: ${e.message}');
      throw PostException('Client error: ${e.message}');
    } on FormatException catch (e) {
      print('⚠️ [PostService] FormatException: ${e.message}');
      throw PostException('Invalid response format: ${e.message}');
    } catch (e, stack) {
      print('🔥 [PostService] Unexpected Error: $e');
      print('🧩 [PostService] Stack Trace: $stack');
      if (e is PostException) rethrow;
      throw PostException('Failed to get my posts: $e');
    }
  }

  /// Update an existing post
  /// PUT /api/posts/{postId}
  Future<PostDetail> updatePost({
    required String accessToken,
    required int postId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/$postId');
      print('✏️ [PostService] Updating post $postId...');
      print('🌐 [PostService] URL: $url');
      print('📦 [PostService] Request Body: ${jsonEncode(updateData)}');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updateData),
      );

      print('📊 [PostService] Response Status: ${response.statusCode}');
      print('📦 [PostService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          print('✅ [PostService] Post updated successfully');
          return PostDetail.fromJson(data);
        } catch (parseError, stack) {
          print('❌ [PostService] JSON Parsing Error: $parseError');
          print('🧩 [PostService] Stack Trace: $stack');
          throw PostException('Failed to parse updated post: $parseError');
        }
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final errorResponse = ErrorResponse.fromJson(errorData);
          print('❌ [PostService] Server Error: ${errorResponse.message}');
          throw PostException(errorResponse.message);
        } catch (e) {
          print('❌ [PostService] Error Response: ${response.body}');
          throw PostException('Server error: ${response.statusCode}');
        }
      }
    } on SocketException catch (e) {
      print('🚫 [PostService] SocketException: ${e.message}');
      throw PostException('Network error: ${e.message}');
    } on http.ClientException catch (e) {
      print('🚨 [PostService] ClientException: ${e.message}');
      throw PostException('Client error: ${e.message}');
    } catch (e, stack) {
      print('🔥 [PostService] Unexpected Error: $e');
      print('🧩 [PostService] Stack Trace: $stack');
      if (e is PostException) rethrow;
      throw PostException('Failed to update post: $e');
    }
  }
}