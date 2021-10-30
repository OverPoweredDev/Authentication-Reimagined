import 'package:http/http.dart' as http;
import 'otp_request_util.dart';

Future<String> generateOTPapi(String aadhar) async{

    requestHandler request = requestHandler.uid(aadhar);
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
    print(response.errcode);
    return Future.value(request.txnId);
}