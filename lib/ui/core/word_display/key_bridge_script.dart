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
/// * The zoom keys are taken over from the engine. It zooms the page on its
///   own for them, which leaves the entry scrolling sideways; the app's own
///   zoom keeps the text and the images in step instead.
/// * `Esc` moves the focus into the search box and selects its text, the same
///   as the app-level shortcut does when Flutter holds the focus.
String keyBridgeScript() {
  return """
(function () {
  function post(name, payload) {
    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
      window.flutter_inappwebview.callHandler('ciyueKey', name, payload || '');
    }
  }
  document.addEventListener('keydown', function (e) {
    if (e.ctrlKey && !e.altKey && !e.metaKey) {
      var key = e.key;
      if (key === '=' || key === '+' || key === '-' || key === '0') {
        // The engine zooms the page for these before they reach anybody
        // else, so they have to be caught here.
        e.preventDefault();
        post('Zoom', key);
        return;
      }
    }
    // The other modified combinations belong to the app's own shortcuts.
    if (e.ctrlKey || e.altKey || e.metaKey) return;

    // Esc moves the focus into the search box and selects its text.
    if (e.key === 'Escape') {
      e.preventDefault();
      post('Escape');
      return;
    }

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
  }, true);
})();
""";
}

/// Selects the word under the pointer on a right click.
///
/// A right click does not raise the long press selection, so the context menu
/// had nothing to look up: this selects the word the menu then reads back. The
/// word granularity is the browser's own, which also copes with the languages
/// that do not separate words with spaces.
String contextWordScript() {
  return """
(function () {
  function selectWordAt(x, y) {
    if (!document.caretRangeFromPoint) return false;
    var range = document.caretRangeFromPoint(x, y);
    if (!range) return false;
    var selection = window.getSelection();
    if (!selection) return false;
    selection.removeAllRanges();
    selection.addRange(range);
    if (selection.modify) {
      selection.modify('move', 'backward', 'word');
      selection.modify('extend', 'forward', 'word');
    }
    return true;
  }
  // pointerdown fires before the native menu and carries the button, so the
  // selection is ready by the time the menu asks for it.
  document.addEventListener('pointerdown', function (e) {
    if (e.button === 2) selectWordAt(e.clientX, e.clientY);
  }, true);
  // Fallback for a WebView that only dispatches contextmenu.
  document.addEventListener('contextmenu', function (e) {
    var selection = window.getSelection();
    if (!selection || selection.toString().trim() === '') {
      selectWordAt(e.clientX, e.clientY);
    }
  }, true);
})();
""";
}
