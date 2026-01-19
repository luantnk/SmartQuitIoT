/// Helper function to format avatar URL
/// Uses Uri.https to properly encode parameters, especially for ui-avatars.com URLs
String formatAvatarUrl(String? url) {
  if (url == null || url.isEmpty) {
    return '';
  }

  // Check if URL is from ui-avatars.com
  if (url.contains('ui-avatars.com')) {
    try {
      // Parse the existing URL
      final uri = Uri.parse(url);
      
      // Extract query parameters
      final queryParams = Map<String, String>.from(uri.queryParameters);
      
      // Ensure format=url is set
      queryParams['format'] = 'url';
      
      // Reconstruct URL using Uri.https to ensure proper encoding
      final encodedUri = Uri.https(
        'ui-avatars.com',
        uri.path,
        queryParams,
      );
      
      return encodedUri.toString();
    } catch (e) {
      // If parsing fails, return original URL with format=url appended
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}format=url';
    }
  }

  // Return original URL if not from ui-avatars.com
  return url;
}

