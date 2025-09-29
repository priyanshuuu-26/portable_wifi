import 'dart:convert';

class WiFiModel {
  final String address;
  final String category;
  final DateTime createdAt;
  final double downloadSpeed;
  final int id;
  final DateTime lastConnectedAt;
  final double lat;
  final double lng;
  final String name;
  final String ssid;
  final String type;
  final DateTime updatedAt;
  final String uuid;

  WiFiModel({
    required this.address,
    required this.category,
    required this.createdAt,
    required this.downloadSpeed,
    required this.id,
    required this.lastConnectedAt,
    required this.lat,
    required this.lng,
    required this.name,
    required this.ssid,
    required this.type,
    required this.updatedAt,
    required this.uuid,
  });

  factory WiFiModel.fromJson(Map<String, dynamic> json) {
    return WiFiModel(
      address: json['address'] ?? '',
      category: json['category'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      downloadSpeed: double.tryParse(json['download_speed'].toString()) ?? 0.0,
      id: int.tryParse(json['id'].toString()) ?? 0,
      lastConnectedAt: DateTime.tryParse(json['last_connected_at'] ?? '') ?? DateTime.now(),
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: double.tryParse(json['lng'].toString()) ?? 0.0,
      name: json['name'] ?? '',
      ssid: json['ssid'] ?? '',
      type: json['type'] ?? '',
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      uuid: json['uuid'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'download_speed': downloadSpeed,
      'id': id,
      'last_connected_at': lastConnectedAt.toIso8601String(),
      'lat': lat,
      'lng': lng,
      'name': name,
      'ssid': ssid,
      'type': type,
      'updated_at': updatedAt.toIso8601String(),
      'uuid': uuid,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
