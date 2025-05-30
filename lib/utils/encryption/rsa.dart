import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart' as d;

class RSAEncryption {
  final parser = RSAKeyParser();
  //encrypted data must be in base 64
  String decrypt({required String privateKey, required String encryptedData}) {
    try {
      final encryptedData_ = Uint8List.fromList(base64Decode(encryptedData));
      // Parse the private key from the PEM format
      final privateKey1 = parser.parse(privateKey) as d.RSAPrivateKey;

      // Create an RSA decrypter with the private key
      final decrypter = Encrypter(RSA(privateKey: privateKey1));

      // Decrypt the data
      final decryptedData = decrypter.decryptBytes(Encrypted(encryptedData_));

      // Convert the decrypted data to a string
      final decryptedText = utf8.decode(decryptedData);

      return decryptedText;
    } catch (e) {
      rethrow;
    }
  }

  String encrypt({required String data, required String publicKey}) {
    final publicKey_ = parser.parse(publicKey) as d.RSAPublicKey;
    final encrypter = Encrypter(RSA(publicKey: publicKey_));
    final encrypted = encrypter.encrypt(data);
    return encrypted.base64;
  }
}
