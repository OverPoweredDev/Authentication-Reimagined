import 'dart:convert';
import 'package:uuid/uuid.dart';


class urlHandler{
  Uri url = Uri.parse("https://stage1.uidai.gov.in/unifiedAppAuthService/api/v2/generate/aadhaar/otp");
}

class requestHandler{
  String? uid;
  String? captchaTxnId;
  String? captchaValue;
  String transactionId = "Init";

  requestHandler(this.uid, this.captchaTxnId,this.captchaValue){
    const uuid = Uuid();
    transactionId = uuid.v4();
  }

  String? getBody(){
    return json.encode({'uidNumber' : uid, 'captchaTxnId' : captchaTxnId, 'captchaValue' : captchaValue, 'transactionID' : "MYAADHAAR:" + transactionId});
  }
}

class responseHandler{
  String? uidNumber;
  String? mobileNumber;
  String? txnId;
  String? status;
  String? message;


  responseHandler(String responsejson){
    var response = jsonDecode(responsejson);
    uidNumber = response['uidNumber'].toString();
    mobileNumber = response['mobileNumber'].toString();
    txnId = response['txnId'].toString();
    status = response['status'].toString();
    message = response ['message'].toString();
  }

}