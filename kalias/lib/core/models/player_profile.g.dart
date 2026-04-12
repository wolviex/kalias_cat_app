// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerProfileAdapter extends TypeAdapter<PlayerProfile> {
  @override
  final typeId = 0;

  @override
  PlayerProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      characterId: fields[2] as String,
      difficultyIndex: (fields[3] as num).toInt(),
      totalXp: fields[4] == null ? 0 : (fields[4] as num).toInt(),
      cycleXp: fields[5] == null ? 0 : (fields[5] as num).toInt(),
      trunkOpenCount: fields[6] == null ? 0 : (fields[6] as num).toInt(),
      lastPlayedAt: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerProfile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.characterId)
      ..writeByte(3)
      ..write(obj.difficultyIndex)
      ..writeByte(4)
      ..write(obj.totalXp)
      ..writeByte(5)
      ..write(obj.cycleXp)
      ..writeByte(6)
      ..write(obj.trunkOpenCount)
      ..writeByte(7)
      ..write(obj.lastPlayedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
