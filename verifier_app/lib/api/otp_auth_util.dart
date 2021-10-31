import 'dart:convert';
import 'dart:io';

class urlHandler{
  Uri url = Uri.parse("https://stage1.uidai.gov.in/onlineekyc/getAuth/");
}

class requestHandler{
  String? uid;
  String? vid;
  String? txnId;
  int? otp;
  requestHandler.vid(this.vid,int otp, String txnId){
    this.txnId = txnId;
    this.otp = otp;
  }
  String? getBody(){
    if(vid == null && uid == null){
      throw Exception("Both uid and vid null");
    }
    else if (uid == null) {
      return json.encode({'vid': vid, 'txnId': txnId, 'otp' : "$otp"});
    }
    else if (vid == null) {
      return json.encode({'uid': uid, 'txnId': txnId, 'otp' : "$otp"});
    }
  }
}

class responseHandler{
  String? status;
  int? errcode;

  responseHandler(String responsejson){
    var response = jsonDecode(responsejson);
    status = response['status'];
    errcode = int.parse(response['errCode'] ?? "0");
  }
}
