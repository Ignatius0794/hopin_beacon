import 'package:flutter/material.dart';
import 'package:qbyt/features/website/presentation/helpers/website_identity.dart';
import 'package:qbyt/features/website/presentation/helpers/website_page_color.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebsitePageInspector {
  const WebsitePageInspector._();

  static bool _isTrue(Object result) =>
      result == true || result == 1 || result.toString() == 'true';

  static Future<bool> isNativeOfflineDocument(
    WebViewController controller,
  ) async {
    final result = await controller.runJavaScriptReturningResult(r"""
      (function () {
        var title = (document.title || '').trim().toLowerCase();
        var text = (document.body && document.body.innerText || '')
          .trim().toLowerCase();
        return text.indexOf('err_internet_disconnected') !== -1 ||
          (title.indexOf('webpage not available') !== -1 &&
            text.indexOf('offline') !== -1);
      })()
    """);
    return _isTrue(result);
  }

  static Future<bool> isHostNotFoundDocument(
    WebViewController controller,
  ) async {
    final result = await controller.runJavaScriptReturningResult(r"""
      (function () {
        var title = (document.title || '').trim().toLowerCase();
        var text = (document.body && document.body.innerText || '')
          .trim().toLowerCase();
        return (title === 'not found' || text.indexOf('not found') === 0) &&
          text.length < 500 &&
          text.indexOf('does not exist') !== -1;
      })()
    """);
    return _isTrue(result);
  }

  static Future<WebsiteIdentity?> identity(
    WebViewController controller,
    Uri pageUri,
  ) async {
    final result = await controller.runJavaScriptReturningResult(r"""
      (function () {
        function read(selector, property) {
          var element = document.querySelector(selector);
          return element ? element[property] : '';
        }
        function structuredLogo() {
          var scripts = document.querySelectorAll(
            'script[type="application/ld+json"]'
          );
          for (var i = 0; i < scripts.length; i++) {
            try {
              var value = JSON.parse(scripts[i].textContent || '{}');
              var entries = Array.isArray(value) ? value : [value];
              for (var j = 0; j < entries.length; j++) {
                var logo = entries[j] && entries[j].logo;
                if (typeof logo === 'string') return logo;
                if (logo && typeof logo.url === 'string') return logo.url;
              }
            } catch (_) {}
          }
          return '';
        }
        var logos = [];
        function addLogo(value) {
          if (value && logos.indexOf(value) === -1) logos.push(value);
        }
        addLogo(read('link[rel="apple-touch-icon"]', 'href'));
        addLogo(read('link[rel="apple-touch-icon-precomposed"]', 'href'));
        addLogo(read('link[rel="shortcut icon"]', 'href'));
        addLogo(read('link[rel~="icon"]', 'href'));
        addLogo(read('meta[property="og:logo"]', 'content'));
        addLogo(read('meta[itemprop="logo"]', 'content'));
        addLogo(structuredLogo());
        addLogo(read('img[itemprop="logo"]', 'src'));
        addLogo(read('img[src*="logo" i]', 'src'));
        addLogo(read('img[class*="logo" i]', 'src'));
        addLogo(read('img[id*="logo" i]', 'src'));
        addLogo(read('img[alt*="logo" i]', 'src'));
        addLogo('/favicon.ico');
        return JSON.stringify({
          name: read('meta[property="og:site_name"]', 'content')
            || read('meta[name="application-name"]', 'content')
            || document.title,
          logos: logos
        });
      })()
    """);
    return WebsiteIdentity.fromJavaScriptResult(result, pageUri);
  }

  static Future<Color?> backgroundColor(
    WebViewController controller,
  ) async {
    final result = await controller.runJavaScriptReturningResult(r"""
      (function () {
        function parseSolidColor(value) {
          if (!value) return null;
          var probe = document.createElement('span');
          probe.style.color = value;
          if (!probe.style.color) return null;
          (document.body || document.documentElement).appendChild(probe);
          var normalized = getComputedStyle(probe).color;
          probe.remove();
          var values = normalized.match(/[\d.]+/g);
          if (!values || values.length < 3) return null;
          if (values.length > 3 && Number(values[3]) === 0) return null;
          return values.slice(0, 3).map(function (channel) {
            return Math.max(0, Math.min(255, Math.round(Number(channel))));
          });
        }

        var theme = document.querySelector('meta[name="theme-color"]');
        var candidates = [
          theme && theme.content,
          document.body && getComputedStyle(document.body).backgroundColor,
          document.documentElement &&
            getComputedStyle(document.documentElement).backgroundColor
        ];
        for (var i = 0; i < candidates.length; i++) {
          var parsed = parseSolidColor(candidates[i]);
          if (parsed) return JSON.stringify(parsed);
        }
        return '';
      })()
    """);
    return WebsitePageColor.fromJavaScriptResult(result);
  }
}
