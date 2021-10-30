import 'package:http/http.dart' as http;
import 'vid_generate_util.dart';

Future<String> generateVidapi(String aadhar,String mobile, int otp, String txnId) async{

  requestHandler request = requestHandler(aadhar, mobile, otp, txnId);
  urlHandler url = urlHandler();
  responseHandler? response;
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
  return Future.value(response.vid);
}