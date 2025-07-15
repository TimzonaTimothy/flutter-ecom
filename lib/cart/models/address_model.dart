class AddressModel {
  int? id;
  double? lat;
  double? lng;
  bool? isDefault;
  String? address;
  String? phone;
  String? addressType;
  String? createdDate;
  String? modifiedDate;
  int? user;

  AddressModel(
      {this.id,
      this.lat,
      this.lng,
      this.isDefault,
      this.address,
      this.phone,
      this.addressType,
      this.createdDate,
      this.modifiedDate,
      this.user});

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lat = json['lat'];
    lng = json['lng'];
    isDefault = json['isDefault'];
    address = json['address'];
    phone = json['phone'];
    addressType = json['addressType'];
    createdDate = json['created_date'];
    modifiedDate = json['modified_date'];
    user = json['user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['isDefault'] = this.isDefault;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['addressType'] = this.addressType;
    data['created_date'] = this.createdDate;
    data['modified_date'] = this.modifiedDate;
    data['user'] = this.user;
    return data;
  }
}
