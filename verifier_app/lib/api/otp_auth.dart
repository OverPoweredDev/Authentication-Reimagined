import 'package:http/http.dart' as http;

import 'otp_auth_util.dart';

Future<bool> verifyOTPapi(String vid, int otp, String txnId) async {
  requestHandler request = requestHandler.vid(vid, otp, txnId);
  urlHandler url = urlHandler();
  responseHandler? response;

  print(request.getBody());

  http.Response httpresponse = await http.post(url.url,
      headers: {'Content-type': 'application/json'}, body: request.getBody());
  if (httpresponse.statusCode == 200) {
    response = responseHandler(httpresponse.body);
  } else {
    print("Kahitari error with status code ${httpresponse.statusCode}");
    throw Exception("http response failed");
  }

  print(response.status);
  print(response.errcode);

  bool verify = false;
  if (response.status == "y" || response.status == "Y") {
    verify = true;
  }

  return Future.value(verify);
}
