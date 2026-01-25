import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class HttpClient {
  // CORS proxy for web testing - only use in development!
  static const String corsProxy = 'https://cors-anywhere.herokuapp.com/';
  
  // Flag to enable/disable CORS proxy (set to false for production)
  static const bool useCorsProxy = false;
  
  static String _getUrl(String url) {
    // Only use CORS proxy for web builds and when enabled
    if (kIsWeb && useCorsProxy) {
      return '$corsProxy$url';
    }
    return url;
  }
  
  static Map<String, String> _getHeaders(Map<String, String>? headers) {
    final Map<String, String> finalHeaders = headers ?? {};
    
    // Add CORS proxy headers if using proxy
    if (kIsWeb && useCorsProxy) {
      finalHeaders['X-Requested-With'] = 'XMLHttpRequest';
    }
    
    return finalHeaders;
  }
  
  static Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final url = _getUrl(uri.toString());
    final finalHeaders = _getHeaders(headers);
    
    return await http.get(
      Uri.parse(url),
      headers: finalHeaders,
    );
  }
  
  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final url = _getUrl(uri.toString());
    final finalHeaders = _getHeaders(headers);
    
    return await http.post(
      Uri.parse(url),
      headers: finalHeaders,
      body: body,
    );
  }
  
  static Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final url = _getUrl(uri.toString());
    final finalHeaders = _getHeaders(headers);
    
    return await http.put(
      Uri.parse(url),
      headers: finalHeaders,
      body: body,
    );
  }

  static Future<http.Response> delete(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final url = _getUrl(uri.toString());
    final finalHeaders = _getHeaders(headers);
    
    return await http.delete(
      Uri.parse(url),
      headers: finalHeaders,
    );
  }
}
