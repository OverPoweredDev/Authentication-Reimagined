import 'package:http/http.dart' as http;
import 'get_ekyc_util.dart';

Future<Map<String,String?>> getEkycapi(String aadhar, String otp, String txnId) async{

  requestHandler request = requestHandler.uid(aadhar, otp, txnId);
  urlHandler url = urlHandler();
  responseHandler? response;
  print(request.uid);
  print(request.getBody());
  http.Response httpresponse = await http.post(url.url,headers: {'Content-type' : 'application/json'},body:request.getBody());
  if (httpresponse.statusCode == 200) {
    response = responseHandler(httpresponse.body);
  }
  else {
    print("Kahitari error with status code ${httpresponse.statusCode}");
    throw Exception("http response failed");
  }

  print(response.status);

  bool verify = false;
  if (response.status == "Success"){
    verify = true;
  }
  return Future.value({'eKycXML' : response.eKycXML , 'filename' : response.fileName});
}