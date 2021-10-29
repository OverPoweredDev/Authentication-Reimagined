package com.example.resident_app;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

///*************************************************
////////////////Copied Imports

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.WebResource;
import com.sun.org.apache.xerces.internal.jaxp.datatype.XMLGregorianCalendarImpl;
import in.gov.uidai.otpapiclient.model.Opts;
import in.gov.uidai.otpapiclient.model.Otp;
import in.gov.uidai.otpapiclient.model.OtpRes;
import in.gov.uidai.otpapiclient.model.Type;
import in.gov.uidai.otpapiclient.util.NamespaceFilter;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.XMLReaderFactory;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import javax.xml.crypto.dsig.*;
import javax.xml.crypto.dsig.dom.DOMSignContext;
import javax.xml.crypto.dsig.keyinfo.KeyInfo;
import javax.xml.crypto.dsig.keyinfo.KeyInfoFactory;
import javax.xml.crypto.dsig.keyinfo.X509Data;
import javax.xml.crypto.dsig.spec.C14NMethodParameterSpec;
import javax.xml.crypto.dsig.spec.TransformParameterSpec;
import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamResult;
import java.io.*;
import java.net.InetAddress;
import java.net.URI;
import java.security.KeyStore;
import java.security.Security;
import java.security.cert.X509Certificate;
import java.util.*;
////////////////END of Copied imports
///************************************************** */

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "javaSignXML";

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
  super.configureFlutterEngine(flutterEngine);

  //////This is borrowed code.
  /////******************************************************************************** */
  private String signXML(String xmlDocument, boolean includeKeyInfo) throws Exception {
    Security.addProvider(new BouncyCastleProvider());
    // Parse the input XML
    DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
    dbf.setNamespaceAware(true);
    Document inputDocument = dbf.newDocumentBuilder().parse(new InputSource(new StringReader(xmlDocument)));

    // Sign the input XML's DOM document
    Document signedDocument = sign(inputDocument, includeKeyInfo);

    // Convert the signedDocument to XML String
    StringWriter stringWriter = new StringWriter();
    TransformerFactory tf = TransformerFactory.newInstance();
    Transformer trans = tf.newTransformer();
    trans.transform(new DOMSource(signedDocument), new StreamResult(stringWriter));

    return stringWriter.getBuffer().toString();
} 
private Document sign(Document xmlDoc, boolean includeKeyInfo) throws Exception {

    // Creating the XMLSignature factory.
    XMLSignatureFactory fac = XMLSignatureFactory.getInstance("DOM");
    // Creating the reference object, reading the whole document for
    // signing.
    Reference ref = fac.newReference("", fac.newDigestMethod(DigestMethod.SHA1, null),
            Collections.singletonList(fac.newTransform(Transform.ENVELOPED, (TransformParameterSpec) null)), null,
            null);

    // Create the SignedInfo.
    SignedInfo sInfo = fac.newSignedInfo(
            fac.newCanonicalizationMethod(CanonicalizationMethod.INCLUSIVE, (C14NMethodParameterSpec) null),
            fac.newSignatureMethod(SignatureMethod.RSA_SHA1, null), Collections.singletonList(ref));

    X509Certificate x509Cert = (X509Certificate) getAuthReqKeyFromKeyStore().getCertificate();

    KeyInfo kInfo = getKeyInfo(x509Cert, fac);
    DOMSignContext dsc = new DOMSignContext(getAuthReqKeyFromKeyStore().getPrivateKey(), xmlDoc.getDocumentElement());
    XMLSignature signature = fac.newXMLSignature(sInfo, includeKeyInfo ? kInfo : null);
    signature.sign(dsc);

    Node node = dsc.getParent();
    return node.getOwnerDocument();

}
private KeyStore.PrivateKeyEntry getAuthReqKeyFromKeyStore() throws Exception {
    try (FileInputStream fileInputStream = new FileInputStream(configProp.getProperty(Constants.SIGNATURE_FILE))){
        KeyStore keyStore = KeyStore.getInstance("PKCS12");
        keyStore.load(fileInputStream, configProp.getProperty(Constants.SIGNATURE_PASSWORD).toCharArray());
        return (KeyStore.PrivateKeyEntry) keyStore.getEntry(configProp.getProperty(Constants.SIGNATURE_ALIAS),
                new KeyStore.PasswordProtection(configProp.getProperty(Constants.SIGNATURE_PASSWORD).toCharArray()));
    }
}

private KeyInfo getKeyInfo(X509Certificate cert, XMLSignatureFactory fac) {
    // Create the KeyInfo containing the X509Data.
    KeyInfoFactory kif = fac.getKeyInfoFactory();
    X509Data xd = kif.newX509Data(Arrays.asList(cert.getSubjectX500Principal().getName(), cert));
    return kif.newKeyInfo(Collections.singletonList(xd));
}

  ///////This is where the borrowrd code ends
  ///************************************************************************* */  
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler(
          (call, result) -> {
            // Note: this method is invoked on the main thread.
            // TODO
          }
        );
  }
}
