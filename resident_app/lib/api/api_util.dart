import 'dart:convert';

import 'dart:io';

class urlHandler{
  Uri url = Uri.parse("https://stage1.uidai.gov.in/onlineekyc/getOtp/");
}

class requestHandler{
  String? uid;
  String? vid;
  String? txnId = "1";

  requestHandler.uid(this.uid);
  requestHandler.vid(this.vid);
  String? getBody(){
    if(vid == null && uid == null){
      throw Exception("Both uid and vid null");
    }
    else if (uid == null) {
      return json.encode({'uid': uid, 'txnid': txnId});
    }
    else if (vid == null) {
      return json.encode({'vid': vid, 'txnid': txnId});
    }
  }
}

class responseHandler{
  String? status;
  int? errcode;

  responseHandler(String responsejson){
    var response = jsonDecode(responsejson);
    status = response['status'];
    print(response['status']);
    print("Test");
    print(response['errCode']);
    print("End test");
    errcode = int.parse(response['errCode']);
  }
}
