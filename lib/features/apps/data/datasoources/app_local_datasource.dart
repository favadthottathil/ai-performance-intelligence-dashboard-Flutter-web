import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_model.dart';

@LazySingleton()
class AppsLocalDataSource {
  static const _storageKey = 'saved_apps_list';

  Future<void> saveApp(AppModel app) async {
    final prefs = await SharedPreferences.getInstance();
    final apps = await getAllApps();
    apps.add(app);

    final String encodedData = json.encode(
      apps.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(_storageKey, encodedData);
  }

  Future<List<AppModel>> getAllApps() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => AppModel.fromJson(e)).toList();
  }
}
