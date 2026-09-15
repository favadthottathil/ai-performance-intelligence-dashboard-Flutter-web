import 'package:equatable/equatable.dart';

class AppModel extends Equatable {
  final String id;
  final String name;
  final String apiKey;

  const AppModel({
    required this.id,
    required this.name,
    required this.apiKey,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      apiKey: json['api_key']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'api_key': apiKey};
  }

  // Value equality keeps bloc states that carry app lists from re-emitting
  // (and rebuilding the dashboard) when nothing has actually changed.
  @override
  List<Object?> get props => [id, name, apiKey];
}
