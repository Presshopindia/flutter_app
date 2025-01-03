import 'package:intl/intl.dart';
import 'package:presshop/utils/Common.dart';

import '../menuScreen/feedScreen/feedDataModel.dart';

class EarningProfileDataModel {
  String id = '';
  String category = '';
  bool isSocialRegister = false;
  String role = '';
  String status = '';
  String hopperUserFirstName = '';
  String hopperUserLastName = '';
  String hopperUserEmail = '';
  String avatarId = '';
  String avatar = '';
  String totalEarning = "";

  EarningProfileDataModel({
    required this.id,
    required this.category,
    required this.isSocialRegister,
    required this.role,
    required this.status,
    required this.hopperUserFirstName,
    required this.hopperUserLastName,
    required this.hopperUserEmail,
    required this.avatarId,
    required this.avatar,
    required this.totalEarning,
  });

  factory EarningProfileDataModel.fromJson(Map<String, dynamic> json) {
    return EarningProfileDataModel(
      id: json['_id'] ?? '',
      category: json['hopper_id'] != null ? json['hopper_id']['category'] : '',
      isSocialRegister: json['hopper_id'] != null
          ? json['hopper_id']['isSocialRegister']
          : false,
      role: json['hopper_id'] != null ? json['hopper_id']['status'] : '',
      status: json['hopper_id'] != null ? json['hopper_id']['_id'] : '',
      hopperUserFirstName:
          json['hopper_id'] != null ? json['hopper_id']['first_name'] : '',
      hopperUserLastName:
          json['hopper_id'] != null ? json['hopper_id']['last_name'] : '',
      hopperUserEmail:
          json['hopper_id'] != null ? json['hopper_id']['email'] : '',
      avatarId:
          json['avatar_details'] != null ? json['avatar_details']['_id'] : '',
      avatar: json['avatar_details'] != null
          ? json['avatar_details']['avatar']
          : '',
      totalEarning: json['total_earining'].toString() ?? '',
    );
  }
}

class EarningTransactionDetail {
  String id = '';
  bool paidStatus = false;
  String adminFullName = "";
  String adminProfileImage = "";
  String adminCountryCode = "";
  int adminPhoneNumber = 0;
  String adminEmail = "";

  String adminAccountName = "";
  String adminBankName = "";
  String adminSortCode = "";
  String adminAccountNumber = "";
  String adminUserName = "";
  String adminRole = "";
  String adminStatus = "";

  String saleStatus = "";
  String contentType = "";
  List<ContentDataModel> contentDataList = [];
  List<BankDataModel> userBankDetailList = [];
  String userFirstName = "";
  String userLastName = "";
  String userEmail = "";
  int userPhone = 0;
  String userAddress = "";
  String vat = '';
  String amount = '';
  String payableT0Hopper = '';
  String payableCommission = '';
  String type = '';
  String typesOfContent = "";
  String createdAT = '';
  String dueDate = '';
  String updatedAT = '';

  EarningTransactionDetail({
    required this.id,
    required this.paidStatus,
    required this.adminFullName,
    required this.adminProfileImage,
    required this.adminCountryCode,
    required this.adminPhoneNumber,
    required this.adminEmail,
    required this.adminAccountName,
    required this.adminBankName,
    required this.adminSortCode,
    required this.adminAccountNumber,
    required this.adminUserName,
    required this.adminRole,
    required this.adminStatus,
    required this.saleStatus,
    required this.contentType,
    required this.contentDataList,
    required this.userBankDetailList,
    required this.userFirstName,
    required this.userLastName,
    required this.userEmail,
    required this.userPhone,
    required this.userAddress,
    required this.vat,
    required this.amount,
    required this.payableT0Hopper,
    required this.payableCommission,
    required this.type,
    required this.typesOfContent,
    required this.createdAT,
    required this.dueDate,
    required this.updatedAT,

  });

  factory EarningTransactionDetail.fromJson(Map<String, dynamic> json) {
    List<BankDataModel> bankData = [];
    List<ContentDataModel> contentData = [];
    if (json['hopper_id'] != null) {
      if (json['hopper_id']['bank_detail'] != null) {
        var data = json['hopper_id']['bank_detail'] as List;
        bankData = data.map((e) => BankDataModel.fromJson(e)).toList();
      }
    }
    if (json['content_id'] != null) {
      if (json['content_id']['content'] != null) {
        var data = json['content_id']['content'] as List;
        contentData = data.map((e) => ContentDataModel.fromJson(e)).toList();
      }
    }
    return EarningTransactionDetail(
      id: json['_id'] ?? '',
      paidStatus: json['paid_status_for_hopper'] ?? false,
      adminFullName: json['media_house_id'] != null
          ? json['media_house_id']['admin_detail']['full_name']
          : '',
      adminProfileImage: json['media_house_id'] != null
          ? json['media_house_id']['admin_detail']['admin_profile']
          : '',
      adminCountryCode: json['media_house_id'] != null
          ? json['media_house_id']['admin_detail']['country_code']
          : '',
      adminPhoneNumber: json['media_house_id'] != null
          ? json['media_house_id']['admin_detail']['phone']
          : 0,
      adminEmail: json['media_house_id'] != null
          ? json['media_house_id']['admin_detail']['email']
          : '',
      adminAccountName: json['media_house_id'] != null
          ? json['media_house_id']['company_bank_details']
              ['company_account_name']
          : '',
      adminBankName: json['media_house_id'] != null
          ? json['media_house_id']['company_bank_details']['bank_name']
          : '',
      adminSortCode: json['media_house_id'] != null
          ? json['media_house_id']['company_bank_details']['sort_code']
          : '',
      adminAccountNumber: json['media_house_id'] != null
          ? json['media_house_id']['company_bank_details']['account_number']
          : '',
      adminUserName: json['media_house_id'] != null
          ? json['media_house_id']['user_name']
          : '',
      adminRole:
          json['media_house_id'] != null ? json['media_house_id']['role'] : '',
      adminStatus: json['media_house_id'] != null
          ? json['media_house_id']['status']
          : '',
      contentType: json['content_id'] != null ? json['content_id']['type'] : '',
      saleStatus:
          json['content_id'] != null ? json['content_id']['sale_status'] : '',
      contentDataList: contentData,
      userBankDetailList: bankData,
      userFirstName:
          json['hopper_id'] != null ? json['hopper_id']['first_name'] : '',
      userLastName:
          json['hopper_id'] != null ? json['hopper_id']['last_name'] : '',
      userEmail: json['hopper_id'] != null ? json['hopper_id']['email'] : '',
      userPhone: json['hopper_id'] != null ? json['hopper_id']['phone'] : 0,
      userAddress:
          json['hopper_id'] != null ? json['hopper_id']['address'] : '',
      vat: json['Vat'].toString() ?? '',
      amount: json['amount'].toString() ?? '',
      payableT0Hopper: json['payable_to_hopper'].toString() ?? '',
      payableCommission: json['presshop_commission'].toString() ?? '',
      type: json['type'] ?? '',
      typesOfContent: json['typeofcontent'] ?? '',
      createdAT: dateTimeFormatter(dateTime: json['createdAt']),
      updatedAT: dateTimeFormatter(dateTime: json['updatedAt']),
      dueDate: dateTimeFormatter(dateTime: json['Due_date']),
    );
  }
}

class BankDataModel {
  bool isDefault = false;
  String id = '';
  String accountHolderName = '';
  String bankName = '';
  String sortCode = '';
  int accountNumber = 0;

  BankDataModel({
    required this.isDefault,
    required this.id,
    required this.accountHolderName,
    required this.bankName,
    required this.sortCode,
    required this.accountNumber,
  });

  factory BankDataModel.fromJson(Map<String, dynamic> json) {
    return BankDataModel(
        isDefault: json['is_default'] ?? false,
        id: json['_id'] ?? '',
        accountHolderName: json['acc_holder_name'] ?? '',
        bankName: json['bank_name'] ?? '',
        sortCode: json['sort_code'] ?? '',
        accountNumber: json['acc_number'] ?? 0);
  }
}
