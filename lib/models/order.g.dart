// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order(
    ordernumber: json['ordernumber'] as String,
    customer: json['customer'] as String,
    street: json['street'] as String,
    city: json['city'] as String,
    postal: json['postal'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String,
    note: json['note'] as String,
    tip: (json['tip'] as num).toDouble(),
    complete: json['complete'] as bool? ?? false,
    id: json['id'] as String?,
    selectedDeliveryTime: json['selectedDeliveryTime'] == null
        ? null
        : DateTime.parse(json['selectedDeliveryTime'] as String),
  );
}

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'ordernumber': instance.ordernumber,
      'customer': instance.customer,
      'street': instance.street,
      'city': instance.city,
      'postal': instance.postal,
      'phone': instance.phone,
      'email': instance.email,
      'note': instance.note,
      'tip': instance.tip,
      'complete': instance.complete,
      'selectedDeliveryTime': instance.selectedDeliveryTime.toIso8601String(),
    };
