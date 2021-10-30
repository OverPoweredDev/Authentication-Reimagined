import 'package:http/http.dart' as http;
import 'captcha_generation_util.dart';

Future<Map<String,String?>> generateCaptchaapi() async{

  requestHandler request = requestHandler();
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
  var retval = { 'captchaBase64String' : response.captchaBase64String, 'captchaTxnId' : response.captchaTxnId};

  return Future.value(retval);
}