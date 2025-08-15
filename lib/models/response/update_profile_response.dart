import 'package:fluttertvtor/models/response/locationresponse.dart';

class UpdateProfileResponse {
  bool? success;
  UpdateProfileData? data;
  String? message;
  int? statusCode;

  UpdateProfileResponse({this.success, this.data, this.message, this.statusCode});

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      success: json['success'],
      data: json['data'] != null ? UpdateProfileData.fromJson(json['data']) : null,
      message: json['message'],
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    data['statusCode'] = statusCode;
    return data;
  }
}

class UpdateProfileData {
  List<String>? location;
  List<String>? subjects;
  bool? status;
  bool? isDeleted;
  List<String>? subjectId;
  List<String>? subjectData;
  List<LocationData>? locationData;
  List<DataItem>? locationList;
  String? managerId;
  String? userType;
  String? sId;
  String? name;
  String? availability;
  String? surname;
  String? imageUrl;
  String? email;
  String? password;
  String? description;
  int? mobileNumber;
  int? code;
  String? createdAt;
  String? updatedAt;
  int? iV;

  UpdateProfileData({
    this.location,
    this.subjects,
    this.status,
    this.isDeleted,
    this.subjectId,
    this.subjectData,
    this.locationData,
    this.managerId,
    this.userType,
    this.sId,
    this.name,
    this.surname,
    this.imageUrl,
    this.email,
    this.password,
    this.availability,
    this.mobileNumber,
    this.code,
    this.description,
    this.locationList,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  factory UpdateProfileData.fromJson(Map<String, dynamic> json) {
    return UpdateProfileData(
      location: json['location'] != null
          ? List<String>.from(json['location'])
          : (json['loctaion'] != null ? List<String>.from(json['loctaion']) : null),
      subjects: json['subjects'] != null
          ? List<String>.from(json['subjects'])
          : null,
      status: json['status'],
      isDeleted: json['isDeleted'],
      description: json['description'],
      availability: json['availability'],
      subjectId: json['subjectId'] != null
          ? List<String>.from(json['subjectId'])
          : null,
      subjectData: json['subjectData'] != null
          ? List<String>.from(json['subjectData'])
          : null,
      locationData: json['locationData'] != null
          ? List<LocationData>.from(json['locationData'])
          : null,
      locationList: json['locationList'] != null
          ? (json['locationList'] as List)
          .map((i) => DataItem.fromJson(i))
          .toList()
          : null,
      managerId: json['managerId'],
      userType: json['userType'],
      sId: json['_id'],
      name: json['name'],
      surname: json['surname'],
      imageUrl: json['imageUrl'],
      email: json['email'],
      password: json['password'],
      mobileNumber: json['mobileNumber'],
      code: json['code'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      iV: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location;
    }
    if (subjects != null) {
      data['subjects'] = subjects;
    }
    data['status'] = status;
    data['isDeleted'] = isDeleted;
    if (subjectId != null) {
      data['subjectId'] = subjectId;
    }
    if (subjectData != null) {
      data['subjectData'] = subjectData;
    }
    if (locationData != null) {
      data['locationData'] = locationData;
    }
    data['description'] = description;
    data['managerId'] = managerId;
    data['userType'] = userType;
    data['_id'] = sId;
    data['name'] = name;
    data['surname'] = surname;
    data['imageUrl'] = imageUrl;
    data['email'] = email;
    data['password'] = password;
    data['availability'] = availability;
    data['mobileNumber'] = mobileNumber;
    data['code'] = code;
    if (locationList != null) {
      data['locationList'] = locationList!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class LocationData {
  final String? id;
  final String? location;

  LocationData({this.id, this.location});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      id: json['_id'] ,
      location: json['location'] ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'location': location,
    };
  }
}
