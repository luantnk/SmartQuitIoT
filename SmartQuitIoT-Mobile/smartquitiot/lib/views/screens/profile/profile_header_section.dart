import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:SmartQuitIoT/utils/avatar_helper.dart';

class ProfileHeaderSection extends StatelessWidget {
  final String name;
  final String status;
  final String avatarPath;

  const ProfileHeaderSection({
    super.key,
    required this.name,
    required this.status,
    required this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = avatarPath.startsWith('http');
    // Format avatar URL to add &format=url for ui-avatars.com
    final String formattedAvatarPath = isNetworkImage 
        ? formatAvatarUrl(avatarPath) 
        : avatarPath;

    return Column(
      children: [
        const SizedBox(height: 20),

        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.white, width: 3),
            ),
          ),
          child: ClipOval(
            child: isNetworkImage
                ? _buildNetworkImage(formattedAvatarPath)
                : Image.asset(
                    formattedAvatarPath,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
          ),
        ),

        const SizedBox(height: 15),

        // Name
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 4),

        // Status
        Text(status, style: TextStyle(fontSize: 14, color: Colors.grey[600])),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNetworkImage(String url) {
    // Try to properly encode the URL
    try {
      final uri = Uri.parse(url);
      final encodedUrl = uri.toString();
      
      return Image.network(
        encodedUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        headers: {
          'Accept': 'image/*',
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ [ProfileHeaderSection] Error loading image: $error');
          print('❌ [ProfileHeaderSection] URL: $url');
          print('❌ [ProfileHeaderSection] Encoded URL: $encodedUrl');
          
          // Fallback: Try loading with http package
          return FutureBuilder<http.Response>(
            future: http.get(Uri.parse(url)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00D09E),
                    ),
                  ),
                );
              }
              
              if (snapshot.hasData && snapshot.data!.statusCode == 200) {
                return Image.memory(
                  snapshot.data!.bodyBytes,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                );
              }
              
              return Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              );
            },
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF00D09E),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('❌ [ProfileHeaderSection] Error parsing URL: $e');
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[200],
        child: const Icon(
          Icons.person,
          size: 50,
          color: Colors.grey,
        ),
      );
    }
  }
}
