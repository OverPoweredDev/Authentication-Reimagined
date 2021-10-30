import 'dart:convert';

import 'dart:io';

class urlHandler{
  Uri url = Uri.parse("https://stage1.uidai.gov.in/onlineekyc/getOtp/");
}

class requestHandler{
  String? uid;
  String? vid;
  String? txnId = "0acbaa8b-b3ae-433d-a5d2-51250ea8e970";

  requestHandler.uid(this.uid);
  requestHandler.vid(this.vid);
  String? getBody(){
    if(vid == null && uid == null){
      throw Exception("Both uid and vid null");
    }
    else if (uid == null) {
      return json.encode({'vid': vid, 'txnId': txnId});
    }
    else if (vid == null) {
      return json.encode({'uid': uid, 'txnId': txnId});
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
