class AddressModel {
  final int? id;
  final double lat;
  final double lng;
  final bool isDefault;
  final String address;
  final String phone;
  final String addressType;
  final String? createdDate;
  final String? modifiedDate;

  AddressModel({
    this.id,
    required this.lat,
    required this.lng,
    required this.isDefault,
    required this.address,
    required this.phone,
    required this.addressType,
    this.createdDate,
    this.modifiedDate,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      isDefault: json['isDefault'] ?? false,
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      addressType: json['addressType'] ?? 'home',
      createdDate: json['created_date'],
      modifiedDate: json['modified_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
      'address': address,
      'phone': phone,
      'addressType': addressType,
    };
  }

  AddressModel copyWith({
    int? id,
    double? lat,
    double? lng,
    bool? isDefault,
    String? address,
    String? phone,
    String? addressType,
    String? createdDate,
    String? modifiedDate,
  }) {
    return AddressModel(
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      addressType: addressType ?? this.addressType,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
    );
  }

  String get displayAddressType {
    switch (addressType.toLowerCase()) {
      case 'home':
        return 'Home';
      case 'office':
        return 'Office';
      case 'school':
        return 'School';
      default:
        return addressType.toUpperCase();
    }
  }
}



// Model for API requests
class CreateAddressModel {
  final double lat;
  final double lng;
  final bool isDefault;
  final String address;
  final String phone;
  final String addressType;

  CreateAddressModel({
    required this.lat,
    required this.lng,
    required this.isDefault,
    required this.address,
    required this.phone,
    required this.addressType,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
      'address': address,
      'phone': phone,
      'addressType': addressType,
    };
  }
}