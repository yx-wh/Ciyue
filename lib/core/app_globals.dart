import "package:ciyue/database/app/app.dart";
import "package:ciyue/database/app/daos.dart";
import "package:material_ui/material_ui.dart";
import "package:flutter_tts/flutter_tts.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:talker_flutter/talker_flutter.dart";

late final Color? accentColor;
final AppDatabase mainDatabase = appDatabase();
late final PackageInfo packageInfo;
late final SharedPreferencesWithCache prefs;
late final VoidCallback refreshAll;
late final FlutterTts flutterTts;
String searchWordFromProcessText = "";

// Each FlutterEngine has its own isolate, so this flag identifies the current
// engine rather than the whole Android process.
bool runningInFloatingWindow = false;

// The controller of the dictionary tab bar.
//
// The shortcut that switches dictionaries lives in the home page, outside
// the entry, so it needs a way to reach the tab bar's controller. The entry
// sets it while the tab layout is on screen and clears it when it leaves.
TabController? dictTabController;

// Pages the entry in the expansion layout.
//
// The expansion layout's scroll controller lives in the entry page, while
// the shortcut that pages it sits in the home page, so the entry hands the
// action over.
void Function(String key)? expansionPageHandler;

// Gives the focus back to the entry WebView.
//
// The Esc shortcut toggles between the search box and the entry. The entry
// holds the native focus, so its controller has to be asked directly.
void Function()? entryFocusHandler;

List<dynamic> ttsEngines = [];
final List<dynamic> ttsLanguages = [];
String? windowsWebview2Directory;

// Daos
final dictGroupDao = DictGroupDao(mainDatabase);
final dictionaryListDao = DictionaryListDao(mainDatabase);
final hunspellSourceDao = HunspellSourceDao(mainDatabase);
final historyDao = HistoryDao(mainDatabase);
final mddAudioListDao = MddAudioListDao(mainDatabase);
final mddAudioResourceDao = MddAudioResourceDao(mainDatabase);
final wordbookDao = WordbookDao(mainDatabase);
final wordbookTagsDao = WordbookTagsDao(mainDatabase);
final flashcardDao = FlashcardDao(mainDatabase);
final writingCheckHistoryDao = WritingCheckHistoryDao(mainDatabase);
final translateHistoryDao = TranslateHistoryDao(mainDatabase);

final talker = TalkerFlutter.init();
