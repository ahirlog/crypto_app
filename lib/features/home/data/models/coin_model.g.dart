// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoinModelAdapter extends TypeAdapter<CoinModel> {
  @override
  final int typeId = 0;

  @override
  CoinModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinModel(
      id: fields[0] as String,
      name: fields[1] as String,
      symbol: fields[2] as String,
      price: fields[3] as double,
      changePercent24h: fields[4] as double,
      volume24h: fields[5] as double,
      marketCap: fields[6] as double,
      imageUrl: fields[7] as String,
      lastUpdated: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CoinModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.symbol)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.changePercent24h)
      ..writeByte(5)
      ..write(obj.volume24h)
      ..writeByte(6)
      ..write(obj.marketCap)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
