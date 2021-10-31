import 'dart:convert';

class urlHandler{
  Uri url = Uri.parse("https://stage1.uidai.gov.in/unifiedAppAuthService/api/v2/get/captcha");
}

class requestHandler{
  String langCode = "en";
  String captchaLength = "3";
  String captchaType = "2";

  requestHandler();

  String? getBody(){
    return json.encode({'langCode' : langCode, 'captchaLength' : captchaLength, 'captchaType' : captchaType});
  }
}

class responseHandler{
  String? status;
  String? captchaBase64String;
  String? captchaTxnId;
  String? requestedDate;
  String? statusCode;
  String? message;

  responseHandler(String responsejson){
    var response = jsonDecode(responsejson);
    status = response['status'];
    captchaBase64String = response['captchaBase64String'];
    captchaTxnId = response['captchaTxnId'];
    requestedDate = response['requestedDate'];
    statusCode = response ['statusCode'].toString();
    message = response['message'];
  }

}