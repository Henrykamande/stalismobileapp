class Loginresponsemodel {
  bool? resultState;
  int? resultCode;
  String? resultDesc;
  ResponseData? responseData;

  Loginresponsemodel(
      {this.resultState, this.resultCode, this.resultDesc, this.responseData});

  Loginresponsemodel.fromJson(Map<String, dynamic> json) {
    resultState = json['ResultState'];
    resultCode = json['ResultCode'];
    resultDesc = json['ResultDesc'];
    responseData = json['ResponseData'] != null
        ? new ResponseData.fromJson(json['ResponseData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ResultState'] = this.resultState;
    data['ResultCode'] = this.resultCode;
    data['ResultDesc'] = this.resultDesc;
    if (this.responseData != null) {
      data['ResponseData'] = this.responseData!.toJson();
    }
    return data;
  }
}

class ResponseData {
  int? id;
  int? role;
  String? name;
  String? authToken;
  List<Stores>? stores;

  ResponseData({this.id, this.role, this.name, this.authToken, this.stores});

  ResponseData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    role = json['role'];
    name = json['name'];
    authToken = json['authToken'];
    if (json['stores'] != null) {
      stores = <Stores>[];
      json['stores'].forEach((v) {
        stores!.add(new Stores.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['role'] = this.role;
    data['name'] = this.name;
    data['authToken'] = this.authToken;
    if (this.stores != null) {
      data['stores'] = this.stores!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Stores {
  int? id;
  String? name;
  int? industryId;
  Null? storeId;
  int? userId;
  Null? location;
  String? subStatus;
  String? storeStatus;
  String? locked;
  Null? deletedAt;
  String? createdAt;
  String? updatedAt;
  int? strType;
  Null? parentID;
  String? docDate;
  Null? description;
  Null? driver;
  int? lines;
  int? lineCost;
  String? manifestCreated;
  Pivot? pivot;

  Stores(
      {this.id,
      this.name,
      this.industryId,
      this.storeId,
      this.userId,
      this.location,
      this.subStatus,
      this.storeStatus,
      this.locked,
      this.deletedAt,
      this.createdAt,
      this.updatedAt,
      this.strType,
      this.parentID,
      this.docDate,
      this.description,
      this.driver,
      this.lines,
      this.lineCost,
      this.manifestCreated,
      this.pivot});

  Stores.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['Name'];
    industryId = json['industry_id'];
    storeId = json['store_id'];
    userId = json['user_id'];
    location = json['Location'];
    subStatus = json['SubStatus'];
    storeStatus = json['StoreStatus'];
    locked = json['Locked'];
    deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    strType = json['StrType'];
    parentID = json['ParentID'];
    docDate = json['DocDate'];
    description = json['Description'];
    driver = json['driver'];
    lines = json['Lines'];
    lineCost = json['LineCost'];
    manifestCreated = json['ManifestCreated'];
    pivot = json['pivot'] != null ? new Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['Name'] = this.name;
    data['industry_id'] = this.industryId;
    data['store_id'] = this.storeId;
    data['user_id'] = this.userId;
    data['Location'] = this.location;
    data['SubStatus'] = this.subStatus;
    data['StoreStatus'] = this.storeStatus;
    data['Locked'] = this.locked;
    data['deleted_at'] = this.deletedAt;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['StrType'] = this.strType;
    data['ParentID'] = this.parentID;
    data['DocDate'] = this.docDate;
    data['Description'] = this.description;
    data['driver'] = this.driver;
    data['Lines'] = this.lines;
    data['LineCost'] = this.lineCost;
    data['ManifestCreated'] = this.manifestCreated;
    if (this.pivot != null) {
      data['pivot'] = this.pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? userId;
  int? storeId;

  Pivot({this.userId, this.storeId});

  Pivot.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    storeId = json['store_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['store_id'] = this.storeId;
    return data;
  }
}
