/// Forwards the keys that the WebView would otherwise swallow.
///
/// A WebView that holds the native focus does not let Flutter see key
/// events, so the shortcuts that must work while an entry is being read are
/// handled here and handed over to Dart through the `ciyueKey` handler.
///
/// * `Enter` looks up the selected text. Like EBWin, this works for any
///   selection, which matters for the languages that do not separate words
///   with spaces: double-clicking only ever selects one part of a German
///   compound or a Japanese phrase, while selecting the whole phrase gets
///   the full form.
/// * `PageUp`/`PageDown` are only forwarded in the expansion layout. There
///   the WebView is as tall as its content and has nothing to scroll, so the
///   outer scroll container has to do the paging.
String keyBridgeScript({required bool isExpansion}) {
  return """
(function () {
  function post(name, payload) {
    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
      window.flutter_inappwebview.callHandler('ciyueKey', name, payload || '');
    }
  }
  document.addEventListener('keydown', function (e) {
    // Modified combinations belong to the app's own shortcuts.
    if (e.ctrlKey || e.altKey || e.metaKey) return;
    var target = e.target;
    var tag = target && target.tagName ? target.tagName.toLowerCase() : '';
    // Enter belongs to the input the user is typing in.
    if (tag === 'input' || tag === 'textarea' || (target && target.isContentEditable)) return;

    if (e.key === 'Enter') {
      var selection = window.getSelection();
      var text = selection ? selection.toString().trim() : '';
      if (!text) return;
      e.preventDefault();
      post('Enter', text);
      return;
    }
    if ($isExpansion && (e.key === 'PageUp' || e.key === 'PageDown')) {
      e.preventDefault();
      post(e.key, '');
    }
  }, true);
})();
""";
}
