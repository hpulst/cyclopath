// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order(
    id: json['id'] as int,
    customer: json['customer'] as String,
    street: json['street'] as String,
    city: json['city'] as String,
    postal: json['postal'] as String,
    selectedDeliveryTime:
        DateTime.parse(json['selectedDeliveryTime'] as String),
    actualArrivalTime: json['actualArrivalTime'] == null
        ? null
        : DateTime.parse(json['actualArrivalTime'] as String),
    tip: (json['tip'] as num?)?.toDouble(),
    note: json['note'] as String?,
    orderStatus: _$enumDecode(_$OrderStatusEnumMap, json['orderStatus']),
  );
}

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'customer': instance.customer,
      'street': instance.street,
      'city': instance.city,
      'postal': instance.postal,
      'selectedDeliveryTime': instance.selectedDeliveryTime.toIso8601String(),
      'actualArrivalTime': instance.actualArrivalTime?.toIso8601String(),
      'tip': instance.tip,
      'note': instance.note,
      'orderStatus': _$OrderStatusEnumMap[instance.orderStatus],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$OrderStatusEnumMap = {
  OrderStatus.placed: 'placed',
  OrderStatus.ready: 'ready',
  OrderStatus.picked: 'picked',
  OrderStatus.riding: 'riding',
  OrderStatus.arrived: 'arrived',
  OrderStatus.delivered: 'delivered',
};
