import 'dart:convert';
import 'dart:io';
import 'dart:math';

class urlHandler{
  Uri url = Uri.parse("https://stage1.uidai.gov.in/eAadhaarService/api/downloadOfflineEkyc");
}

class requestHandler{
  String? txnNumber;
  String? otp;
  String? shareCode;
  String? uid;
  String? vid;

  requestHandler.uid(this.uid,this.otp,this.txnNumber){
    var random = Random(10);
    shareCode = random.nextInt(9999).toString();
  }
  requestHandler.vid(this.vid,this.otp,this.txnNumber){
    var random = Random(10);
    shareCode = random.nextInt(9999).toString();
  }

  String? getBody() {
    if(vid == null && uid == null){
      throw Exception("Both uid and vid null");
    }
    else if (vid == null) {
      return json.encode({'txnNumber': txnNumber, 'otp': otp, 'shareCode' : shareCode, 'uid' : uid });
    }
    else if (uid == null) {
      return json.encode({'txnNumber': txnNumber, 'otp': otp, 'shareCode' : shareCode, 'vid' : vid });
    }
  }
}

class responseHandler{
  String? eKycXML;
  String? fileName;
  String? status;
  String? requestDate;
  String? uidNumber;

  responseHandler(String responsejson){
    var response = jsonDecode(responsejson);
    eKycXML = response['eKycXML'].toString();
    fileName = response['fileName'].toString();
    status = response['status'].toString();
    requestDate = response['requestDate'].toString();
    uidNumber = response['uidNumber'].toString();
  }
}
