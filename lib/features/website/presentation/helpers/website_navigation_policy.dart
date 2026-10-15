class WebsiteNavigationPolicy {
  const WebsiteNavigationPolicy._();

  static bool sameDocument(String first, String second) {
    final firstUri = Uri.tryParse(first);
    final secondUri = Uri.tryParse(second);
    if (firstUri == null || secondUri == null) return false;
    return firstUri.replace(fragment: '') == secondUri.replace(fragment: '');
  }

  static bool sameOrigin(Uri first, Uri second) =>
      first.scheme == second.scheme &&
      first.host == second.host &&
      first.port == second.port;

  static bool canOpenExternally(Uri uri) {
    if (!uri.hasScheme) return false;
    return !{'javascript', 'data', 'blob', 'about', 'file', 'content'}
        .contains(uri.scheme.toLowerCase());
  }

  static bool looksLikeDownload(Uri uri) {
    const extensions = {
      'apk',
      'csv',
      'doc',
      'docx',
      'pdf',
      'ppt',
      'pptx',
      'rar',
      'tar',
      'xls',
      'xlsx',
      'zip',
    };
    final lastSegment = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
    final extension = lastSegment.contains('.')
        ? lastSegment.split('.').last.toLowerCase()
        : '';
    if (extensions.contains(extension)) return true;
    final path = uri.path.toLowerCase();
    if (path.contains('/download') || path.contains('/export')) return true;
    final download = uri.queryParameters['download']?.toLowerCase();
    return download == '1' || download == 'true';
  }
}
