import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'app/app.dart';
import 'core/constants/app_constants.dart';
import 'features/contacts/domain/entities/emergency_contact.dart';
import 'features/emergency/domain/entities/emergency_event_log.dart';

// Arka plandaki Node.js sunucusuna veri gönderen fonksiyon
Future<void> sendEmergencyLogToBackend(String userName, String status) async {
  final url = Uri.parse('http://10.0.2.2:5000/api/emergency');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_name': userName, 'status': status}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("Sunucu Baglantisi Basarili: Veri PostgreSQL'e yazildi.");
    } else {
      debugPrint("Sunucu hata dondu: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Sunucuya baglanilamadi (Backend acik mi?): $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(EmergencyContactAdapter.typeIdConst)) {
    Hive.registerAdapter(EmergencyContactAdapter());
  }
  if (!Hive.isAdapterRegistered(EmergencyEventLogAdapter.typeIdConst)) {
    Hive.registerAdapter(EmergencyEventLogAdapter());
  }

  await Hive.openBox<EmergencyContact>(AppConstants.contactsBoxName);
  await Hive.openBox<EmergencyEventLog>(AppConstants.emergencyLogsBoxName);

  // Test Amacýyla: Uygulama her açýldýðýnda sunucuya sinyal gönderiyoruz
  await sendEmergencyLogToBackend("Nurbahar Gokgul", "Uygulama Baslatildi");

  runApp(const ProviderScope(child: SosHelpApp()));
}
