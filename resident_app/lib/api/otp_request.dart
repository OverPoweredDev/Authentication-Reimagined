import 'package:http/http.dart' as http;
import 'api_util.dart';

Future<int> generateOTPapi(String aadhar) async{

    requestHandler request = requestHandler.uid(aadhar);
    print("ithe aaloy");
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
    return Future.value(response.errcode);
}