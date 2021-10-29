import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'api_util.dart';

Future<int> generateOTP(int aadhar) async {
  urlHandler url = urlHandler(aadhar);
  RequestHandler request = RequestHandler(aadhar);
  xml.XmlDocument requestXML = request.buildXML();
  xml.XmlDocument signedXML = await request.signXML(requestXML);
  ResponseHandler? response;
  http.Response httpresponse = await http.post(url.url,
      headers: {'Content-type': 'application/xml'}, body: signedXML);
  if (httpresponse.statusCode == 200) {
    response = ResponseHandler(httpresponse.body);
  } else {
    print("Kahitari error with status code ${httpresponse.statusCode}");
    throw Exception("http response failerd");
  }
  var error = response.err;
  return Future.value(error);
}
