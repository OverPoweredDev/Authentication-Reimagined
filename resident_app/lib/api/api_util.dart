import 'dart:html';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart' as xml;

class urlHandler {
  var ver = 2.5;
  var ac = "public";
  var asalk = "MEY2cG1nhC02dzj6hnqyKN2A1u6U0LcLAYaPBaLI-3qE-FtthtweGuk";
  int uid = 99;
  var host = "auth.uidai.gov.in";
  var url;

  urlHandler(int aadhar) {
    uid = aadhar ~/ 10000000000;
    url = Uri.parse('https://$host/otp/$ver/$ac/$uid/$asalk/');
  }
}

class RequestHandler {
  int? uid;
  String ac;
  String sa;
  double version;
  int txn = 7; // TODO unique transaction id system
  String ts = "2021-10-28T23:38:00"; //TODO timestamp sys
  String lk;
  //TODO implement type
  //TODO implement opts
  //TODO sign xml document
  static const javaSignXML = MethodChannel('javaSignXML');

  RequestHandler(this.uid,
      [this.ac = "public",
      this.sa = "public",
      this.version = 2.5,
      this.lk = "MAElpSz56NccNf11_wSM_RrXwa7n8_CaoWRrjYYWouA1r8IoJjuaGYg"]);

  xml.XmlDocument buildXML() {
    var otpRequestXMLBuilder = xml.XmlBuilder();
    otpRequestXMLBuilder.processing(
        'xml', 'version="1.0" encoding="UTF-8" standalone="yes"');
    otpRequestXMLBuilder.element('otp', nest: () {
      otpRequestXMLBuilder.attribute('uid', '$uid');
      otpRequestXMLBuilder.attribute('ac', ac);
      otpRequestXMLBuilder.attribute('sa', sa);
      otpRequestXMLBuilder.attribute('ver', version);
      otpRequestXMLBuilder.attribute('txn', '$txn');
      otpRequestXMLBuilder.attribute('ts', ts);
      otpRequestXMLBuilder.attribute('lk', lk);
    });
    var otpXML = otpRequestXMLBuilder.buildDocument();
    return otpXML;
  }

  Future<xml.XmlDocument> signXML(xml.XmlDocument unisignedXML) async {
    try {
      final signedXML = await javaSignXML.invokeMethod('javaSignXML');
      return signedXML;
    } on PlatformException catch (e) {
      print(e.message);
      return xml.XmlDocument.parse("Null");
    }
  }
}

class ResponseHandler {
  String? ret;
  String? code;
  int? txn;
  int? err;
  xml.XmlDocument? info;
  ResponseHandler(String responseXML) {
    xml.XmlDocument document = xml.XmlDocument.parse(responseXML);
    ret = document.rootElement.getAttribute('ret');
    code = document.rootElement.getAttribute('code');
    txn = int.parse(document.rootElement.getAttribute('txn') ?? '0');
    err = int.parse(document.rootElement.getAttribute('err') ?? '0');
    info = xml.XmlDocument.parse(document.rootElement.getAttribute('info') ??
        'Error'); //TODO handle this better pls
  }
}
