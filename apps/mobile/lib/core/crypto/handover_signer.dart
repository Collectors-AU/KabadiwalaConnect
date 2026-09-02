import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class HandoverSigner {
  static Map<String, dynamic> createSignedLot({
    required String collectorId,
    required String categoryCode,
    required double weightKg,
    required double valuationInr,
    required String geohash,
    required String deviceSalt,
  }) {
    final isoTimestamp = DateTime.now().toUtc().toIso8601String();
    
    // Canonical preimage
    final preimage = "$collectorId|$isoTimestamp|$geohash|${weightKg.toStringAsFixed(2)}|$categoryCode|$deviceSalt";
    
    final bytes = utf8.encode(preimage);
    final digest = sha256.convert(bytes);
    
    // Derive 4-digit numeric PIN
    final digestBytes = digest.bytes;
    int rawUint32 = (digestBytes[0] << 24) | (digestBytes[1] << 16) | (digestBytes[2] << 8) | digestBytes[3];
    String pin = (rawUint32.abs() % 10000).toString().padLeft(4, '0');
    
    return {
      'txn_id': const Uuid().v4(),
      'collector_id': collectorId,
      'timestamp_utc': isoTimestamp,
      'category_code': categoryCode,
      'weight_kg': weightKg,
      'estimated_val_inr': valuationInr,
      'geohash': geohash,
      'sha256_hash': digest.toString(),
      'pin': pin,
    };
  }
}
