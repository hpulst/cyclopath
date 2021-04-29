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
    phone: json['phone'] as String,
    email: json['email'] as String?,
    tip: (json['tip'] as num?)?.toDouble(),
    note: json['note'] as String?,
  );
}

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'customer': instance.customer,
      'street': instance.street,
      'city': instance.city,
      'postal': instance.postal,
      'phone': instance.phone,
      'email': instance.email,
      'tip': instance.tip,
      'note': instance.note,
    };
