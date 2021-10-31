import 'dart:convert';
import 'dart:io';

class urlHandler{
  Uri url = Uri.parse("https://stage1.uidai.gov.in/vidwrapper/generate");
}

class requestHandler{
  String? uid;
  String? mobile;
  String? otpTxnId;
  int? otp;

  requestHandler(this.uid,String mobile, int otp, String otpTxnId){
    this.otpTxnId = otpTxnId;
    this.otp = otp;
    this.mobile = mobile;
  }

  String? getBody() {
    return json.encode({'uid': uid, 'mobile': "$mobile", 'otp': "$otp" , 'otpTxnId' : "$otpTxnId"});
  }
}

class responseHandler{
  String? status;
  String? vid;
  String? message;
  String? errorCode;

  responseHandler(String responsejson){
    var response = jsonDecode(responsejson);
    status = response['status'];
    vid = response['vid'];
    message = response['message'];
    errorCode = response['errorCode'];
  }
}
