// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CheckInAdapter extends TypeAdapter<CheckIn> {
  @override
  final int typeId = 1;

  @override
  CheckIn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckIn(
      id: fields[0] as String,
      habitId: fields[1] as String,
      date: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CheckIn obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckInAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
