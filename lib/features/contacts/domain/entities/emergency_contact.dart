import 'package:hive/hive.dart';

class EmergencyContact {
  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.isPrimary,
  });

  final String id;
  final String name;
  final String phone;
  final bool isPrimary;

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

class EmergencyContactAdapter extends TypeAdapter<EmergencyContact> {
  static const int typeIdConst = 1;

  @override
  final int typeId = typeIdConst;

  @override
  EmergencyContact read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{};

    for (var i = 0; i < fieldCount; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return EmergencyContact(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      isPrimary: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, EmergencyContact obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.isPrimary);
  }
}
