import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String id;
  final String name;
  final bool canSend;
  final bool canReceive;

  DeviceModel({
    required this.id,
    required this.name,
    required this.canSend,
    required this.canReceive,
  });

  factory DeviceModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DeviceModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Device',
      canSend: data['canSend'] ?? false,
      canReceive: data['canReceive'] ?? false,
    );
  }
}
