import 'package:http/http.dart' as http;
import 'vid_otp_request_util.dart';

Future<String> vidGenerateOTPapi(String aadhar,String captchaTxnId, String captchaValue) async{

  requestHandler request = requestHandler(aadhar,captchaTxnId,captchaValue);
  urlHandler url = urlHandler();
  responseHandler? response;
  print(request.getBody());
  http.Response httpresponse = await http.post(url.url,headers: {'x-request-id' : request.transactionId, 'appid' : 'MYAADHAAR','Accept-Language' : 'en_in','Content-type' : 'application/json'},body:request.getBody());
  if (httpresponse.statusCode == 200) {
    response = responseHandler(httpresponse.body);
  }
  else {
    print("Kahitari error with status code ${httpresponse.statusCode}");
    throw Exception("http response failed");
  }

  print(response.mobileNumber);

  return Future.value(response.txnId);
}