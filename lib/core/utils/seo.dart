import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

// A highly improved SEO helper for Flutter Web.
// Safe for mobile platforms (no Web errors).
class SEO {
  // Set full SEO metadata for a page.
  static void set({
    required String title,
    required String description,
    String? keywords,
    String? image,
    String? canonicalUrl,
    String? robots,
    Map<String, dynamic>? jsonLd, // Structured data (schema.org)
  }) {
    if (!kIsWeb) return; // Skip SEO on mobile apps

    _setTitle(title);
    _setDescription(description);
    if (keywords != null) _setKeywords(keywords);
    if (robots != null) _setRobots(robots);
    _setCanonical(canonicalUrl ?? html.window.location.href);

    // Open Graph
    _setOG("og:title", title);
    _setOG("og:description", description);
    _setOG("og:url", canonicalUrl ?? html.window.location.href);
    if (image != null) _setOG("og:image", image);

    // Twitter Card
    _setMeta("twitter:title", title);
    _setMeta("twitter:description", description);
    if (image != null) _setMeta("twitter:image", image);
    _setMeta("twitter:card", "summary_large_image");

    // Inject JSON-LD structured data
    if (jsonLd != null) _setJsonLd(jsonLd);
  }

  // ----------------------------
  // TITLE
  // ----------------------------
  static void _setTitle(String title) {
    html.document.title = title;
  }

  // ----------------------------
  // DESCRIPTION
  // ----------------------------
  static void _setDescription(String content) {
    _setMeta("description", content);
  }

  // ----------------------------
  // KEYWORDS
  // ----------------------------
  static void _setKeywords(String content) {
    _setMeta("keywords", content);
  }

  // ----------------------------
  // ROBOTS
  // ----------------------------
  static void _setRobots(String content) {
    _setMeta("robots", content);
  }

  // ----------------------------
  // CANONICAL URL
  // ----------------------------
  static void _setCanonical(String url) {
    var canonical = html.document.querySelector("link[rel='canonical']");
    if (canonical == null) {
      canonical = html.LinkElement()
        ..rel = 'canonical'
        ..id = "canonical";
      html.document.head!.append(canonical);
    }
    (canonical as html.LinkElement).href = url;
  }

  // ----------------------------
  // OG META
  // ----------------------------
  static void _setOG(String property, String content) {
    var meta = html.document.querySelector("meta[property='$property']");
    if (meta == null) {
      meta = html.MetaElement()..setAttribute('property', property);
      html.document.head!.append(meta);
    }
    meta.setAttribute('content', content);
  }

  // ----------------------------
  // NORMAL META
  // ----------------------------
  static void _setMeta(String name, String content) {
    var meta = html.document.querySelector("meta[name='$name']");
    if (meta == null) {
      meta = html.MetaElement()..name = name;
      html.document.head!.append(meta);
    }
    (meta as html.MetaElement).content = content;
  }

  // ----------------------------
  // STRUCTURED DATA (JSON-LD)
  // ----------------------------
  static void _setJsonLd(Map<String, dynamic> json) {
    // Remove existing JSON-LD if exists
    final existingScripts = html.document.querySelectorAll("script[type='application/ld+json']");
    for (final element in existingScripts) {
      element.remove();
    }

    final script = html.ScriptElement()
      ..type = "application/ld+json"
      ..text = _jsonEncode(json);

    html.document.head!.append(script);
  }

  // Safe JSON encoding helper
  static String _jsonEncode(Map<String, dynamic> json) {
    // Simple JSON encoding without external dependencies
    final encoded = _encodeJsonValue(json);
    return encoded;
  }

  static String _encodeJsonValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"${_escapeJsonString(value)}"';
    if (value is num || value is bool) return value.toString();
    if (value is List) {
      final items = value.map((e) => _encodeJsonValue(e)).join(',');
      return '[$items]';
    }
    if (value is Map) {
      final pairs = value.entries.map((e) =>
      '"${_escapeJsonString(e.key)}":${_encodeJsonValue(e.value)}').join(',');
      return '{$pairs}';
    }
    return '"${_escapeJsonString(value.toString())}"';
  }

  // Basic JSON string escaping
  static String _escapeJsonString(String input) {
    return input
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\t', r'\t')
        .replaceAll('\b', r'\b')
        .replaceAll('\f', r'\f');
  }

  // Clear all SEO metadata (useful for cleanup)
  static void clear() {
    if (!kIsWeb) return;

    // Clear title
    html.document.title = '';

    // Clear meta tags
    final metaTagsToRemove = [
      'description',
      'keywords',
      'robots',
      'twitter:title',
      'twitter:description',
      'twitter:image',
      'twitter:card'
    ];

    for (final name in metaTagsToRemove) {
      final meta = html.document.querySelector("meta[name='$name']");
      meta?.remove();
    }

    // Clear OG tags
    final ogTags = html.document.querySelectorAll("meta[property^='og:']");
    for (final tag in ogTags) {
      tag.remove();
    }

    // Clear canonical
    final canonical = html.document.querySelector("link[rel='canonical']");
    canonical?.remove();

    // Clear JSON-LD
    final jsonLdScripts = html.document.querySelectorAll("script[type='application/ld+json']");
    for (final script in jsonLdScripts) {
      script.remove();
    }
  }
}