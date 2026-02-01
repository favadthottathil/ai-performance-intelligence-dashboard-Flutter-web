class AppModel {
  final String id;
  final String name;
  final String apiKey;

  AppModel({required this.id, required this.name, required this.apiKey});

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      apiKey: json['api_key'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'api_key': apiKey};
  }
}
