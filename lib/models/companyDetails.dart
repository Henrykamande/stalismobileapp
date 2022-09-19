// To parse this JSON data, do
//
//     final companyDetails = companyDetailsFromJson(jsonString);

import 'dart:convert';

CompanyDetails companyDetailsFromJson(String str) =>
    CompanyDetails.fromJson(json.decode(str));

String companyDetailsToJson(CompanyDetails data) => json.encode(data.toJson());

class CompanyDetails {
  CompanyDetails({
    this.resultState,
    this.resultCode,
    this.resultDesc,
    this.responseData,
  });

  bool? resultState;
  int? resultCode;
  String? resultDesc;
  ShopDetailResponseData? responseData;

  factory CompanyDetails.fromJson(Map<String, dynamic> json) => CompanyDetails(
        resultState: json["ResultState"],
        resultCode: json["ResultCode"],
        resultDesc: json["ResultDesc"],
        responseData: ShopDetailResponseData.fromJson(json["ResponseData"]),
      );

  Map<String, dynamic> toJson() => {
        "ResultState": resultState,
        "ResultCode": resultCode,
        "ResultDesc": resultDesc,
        "ResponseData": responseData?.toJson(),
      };
}

class ShopDetailResponseData {
  ShopDetailResponseData({
    required this.id,
    required this.userId,
    this.defaultStockStore,
    required this.slgPrcFixed,
    required this.pAccountCheck,
    required this.eAccountCheck,
    this.oACTSId,
    required this.defaultCustomer,
    required this.defaultBrand,
    required this.defaultCategory,
    required this.imei,
    required this.soldBy,
    required this.mulitplePayment,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.smsEnable,
    required this.enablePriceList,
    this.oPLNSId,
    required this.smsRef,
    required this.sellDeficit,
    required this.combinedStock,
    required this.transferStock,
    required this.advancedMenu,
    required this.uomSetup,
    this.companyName,
    this.companyPhone,
    this.companyEmail,
    this.pinNo,
    this.notificationEmail,
    this.physicalAddress,
    required this.transferDeficit,
    required this.invoicesEdit,
    required this.accountsVersion,
    required this.rmbCnv,
    required this.clearDate,
    required this.dateReadonly,
    required this.combinedDebtors,
    required this.autoSuspendSystem,
    required this.frozenFrom,
    required this.frozenTo,
    this.defaultStore,
    required this.acceptTransfer,
    this.defaultProduct,
    this.currentTax,
  });

  int id;
  int userId;
  dynamic defaultStockStore;
  String slgPrcFixed;
  String pAccountCheck;
  String eAccountCheck;
  dynamic oACTSId;
  int defaultCustomer;
  int defaultBrand;
  int defaultCategory;
  String imei;
  String soldBy;
  String mulitplePayment;
  dynamic deletedAt;
  DateTime createdAt;
  DateTime updatedAt;
  String smsEnable;
  String enablePriceList;
  dynamic oPLNSId;
  String smsRef;
  String sellDeficit;
  String combinedStock;
  String transferStock;
  String advancedMenu;
  String uomSetup;
  dynamic companyName;
  dynamic companyPhone;
  dynamic companyEmail;
  dynamic pinNo;
  dynamic notificationEmail;
  dynamic physicalAddress;
  String transferDeficit;
  String invoicesEdit;
  String accountsVersion;
  int rmbCnv;
  String clearDate;
  String dateReadonly;
  String combinedDebtors;
  String autoSuspendSystem;
  String frozenFrom;
  String frozenTo;
  dynamic? defaultStore;
  String acceptTransfer;
  dynamic? defaultProduct;
  dynamic? currentTax;

  factory ShopDetailResponseData.fromJson(Map<String, dynamic> json) =>
      ShopDetailResponseData(
        id: json["id"],
        userId: json["user_id"],
        defaultStockStore: json["DefaultStockStore"],
        slgPrcFixed: json["SlgPrcFixed"],
        pAccountCheck: json["PAccountCheck"],
        eAccountCheck: json["EAccountCheck"],
        oACTSId: json["o_a_c_t_s_id"],
        defaultCustomer: json["DefaultCustomer"],
        defaultBrand: json["defaultBrand"],
        defaultCategory: json["defaultCategory"],
        imei: json["IMEI"],
        soldBy: json["SoldBy"],
        mulitplePayment: json["MulitplePayment"],
        deletedAt: json["deleted_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        smsEnable: json["smsEnable"],
        enablePriceList: json["enablePriceList"],
        oPLNSId: json["o_p_l_n_s_id"],
        smsRef: json["smsRef"],
        sellDeficit: json["SellDeficit"],
        combinedStock: json["CombinedStock"],
        transferStock: json["TransferStock"],
        advancedMenu: json["AdvancedMenu"],
        uomSetup: json["uomSetup"],
        companyName: json["CompanyName"],
        companyPhone: json["CompanyPhone"],
        companyEmail: json["CompanyEmail"],
        pinNo: json["PinNo"],
        notificationEmail: json["NotificationEmail"],
        physicalAddress: json["PhysicalAddress"],
        transferDeficit: json["TransferDeficit"],
        invoicesEdit: json["InvoicesEdit"],
        accountsVersion: json["AccountsVersion"],
        rmbCnv: json["RmbCnv"],
        clearDate: json["clearDate"],
        dateReadonly: json["dateReadonly"],
        combinedDebtors: json["CombinedDebtors"],
        autoSuspendSystem: json["AutoSuspendSystem"],
        frozenFrom: json["FrozenFrom"],
        frozenTo: json["FrozenTo"],
        defaultStore: json["defaultStore"],
        acceptTransfer: json["acceptTransfer"],
        defaultProduct: json["DefaultProduct"],
        currentTax: json["CurrentTax"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "DefaultStockStore": defaultStockStore,
        "SlgPrcFixed": slgPrcFixed,
        "PAccountCheck": pAccountCheck,
        "EAccountCheck": eAccountCheck,
        "o_a_c_t_s_id": oACTSId,
        "DefaultCustomer": defaultCustomer,
        "defaultBrand": defaultBrand,
        "defaultCategory": defaultCategory,
        "IMEI": imei,
        "SoldBy": soldBy,
        "MulitplePayment": mulitplePayment,
        "deleted_at": deletedAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "smsEnable": smsEnable,
        "enablePriceList": enablePriceList,
        "o_p_l_n_s_id": oPLNSId,
        "smsRef": smsRef,
        "SellDeficit": sellDeficit,
        "CombinedStock": combinedStock,
        "TransferStock": transferStock,
        "AdvancedMenu": advancedMenu,
        "uomSetup": uomSetup,
        "CompanyName": companyName,
        "CompanyPhone": companyPhone,
        "CompanyEmail": companyEmail,
        "PinNo": pinNo,
        "NotificationEmail": notificationEmail,
        "PhysicalAddress": physicalAddress,
        "TransferDeficit": transferDeficit,
        "InvoicesEdit": invoicesEdit,
        "AccountsVersion": accountsVersion,
        "RmbCnv": rmbCnv,
        "clearDate": clearDate,
        "dateReadonly": dateReadonly,
        "CombinedDebtors": combinedDebtors,
        "AutoSuspendSystem": autoSuspendSystem,
        "FrozenFrom": frozenFrom,
        "FrozenTo": frozenTo,
        "defaultStore": defaultStore,
        "acceptTransfer": acceptTransfer,
        "DefaultProduct": defaultProduct,
        "CurrentTax": currentTax,
      };
}
