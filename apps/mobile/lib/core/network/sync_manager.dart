import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../database/models/transaction_model.dart';
import '../database/models/traceability_model.dart';
import '../constants/app_constants.dart';

class SyncResult {
  final bool success;
  final int count;
  final String message;

  SyncResult({required this.success, required this.count, required this.message});
}

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  static String serverHost = "192.168.1.29";
  String get apiEndpoint => "http://$serverHost:8000/api/v1/sync";

  void initSyncListener() {
    // Fire a sync immediately on app boot
    processOutboxQueue();
    
    Connectivity().onConnectivityChanged.listen((dynamic result) {
      if (result is List) {
        if (result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi)) {
          processOutboxQueue();
        }
      } else {
        if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
          processOutboxQueue();
        }
      }
    });
  }

  Future<SyncResult> processOutboxQueue() async {
    try {
      final dynamic connectivityResult = await Connectivity().checkConnectivity();
      bool hasConnection = false;
      
      if (connectivityResult is List) {
        hasConnection = connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi);
      } else {
        hasConnection = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
      }
      
      if (!hasConnection) return SyncResult(success: false, count: 0, message: "No internet connection available.");

      final transactionsBox = Hive.box<TransactionModel>('transactionsBox');
      final traceBox = Hive.box<TraceabilityModel>('traceabilityBox');
      
      // Filter HANDOVER_COMPLETE transactions
      final pendingTxns = transactionsBox.values.where((txn) => txn.status == 'HANDOVER_COMPLETE').toList();
      
      if (pendingTxns.isEmpty) return SyncResult(success: true, count: 0, message: "No pending transactions to sync.");

      final List<Map<String, dynamic>> pendingList = pendingTxns.map((txn) {
        final trace = traceBox.values.firstWhere((t) => t.lotId == txn.lotId);
        final categoryIndex = AppConstants.eWasteCategories.indexOf(txn.categoryCode);
        
        return {
          'txn_id': txn.txnId,
          'lot_id': txn.lotId,
          'collector_id': 1,
          'category_code': categoryIndex >= 0 ? categoryIndex + 1 : 1,
          'approx_weight_kg': txn.finalWeightKg,
          'estimated_val_inr': txn.totalPayoutInr,
          'sha256_hash': trace.sha256Hash,
          'handover_gps': '${trace.latitude},${trace.longitude}',
          'timestamp_utc': trace.timestampUtc.toIso8601String(),
          'status': txn.status,
        };
      }).toList();

      final payload = {
        'device_id': 'MBL-EXP-01',
        'synced_at': DateTime.now().toUtc().toIso8601String(),
        'pending_transactions': pendingList,
      };

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final syncedIds = List<String>.from(data['synced_txn_ids'] ?? []);
        
        int successCount = 0;
        for (var txn in pendingTxns) {
          if (syncedIds.contains(txn.txnId)) {
            txn.status = 'SYNCED_TO_SERVER';
            txn.save();
            successCount++;
          }
        }
        return SyncResult(success: true, count: successCount, message: "Successfully synced $successCount transactions to dashboard!");
      } else {
        return SyncResult(success: false, count: 0, message: "Server Error: ${response.statusCode}");
      }
    } on SocketException catch (_) {
      return SyncResult(success: false, count: 0, message: "Network is unreachable (Is serverHost correct?)");
    } on TimeoutException catch (_) {
      return SyncResult(success: false, count: 0, message: "Request timed out (Check IP or firewall).");
    } catch (e) {
      return SyncResult(success: false, count: 0, message: "Sync error: $e");
    }
  }
}
