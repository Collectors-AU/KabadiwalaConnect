import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../database/models/transaction_model.dart';
import '../database/models/traceability_model.dart';
import '../constants/app_constants.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  static const String emulatorUrl = "http://10.0.2.2:8000/api/v1/sync";
  static const String lanUrl = "http://192.168.1.35:8000/api/v1/sync"; // Fallback LAN IP
  final String apiEndpoint = lanUrl; 

  void initSyncListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        _syncPendingTransactions();
      }
    });
  }

  Future<void> _syncPendingTransactions() async {
    try {
      final transactionsBox = Hive.box<TransactionModel>('transactionsBox');
      final traceBox = Hive.box<TraceabilityModel>('traceabilityBox');
      
      // Query LOCAL_PENDING transactions
      final pendingTxns = transactionsBox.values.where((txn) => txn.status == 'LOCAL_PENDING').toList();
      
      if (pendingTxns.isEmpty) return;

      final List<Map<String, dynamic>> payload = pendingTxns.map((txn) {
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

      final body = {
        'device_id': 'DEVICE_DEMO_01',
        'synced_at': DateTime.now().toUtc().toIso8601String(),
        'pending_transactions': payload,
      };

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Update local status to SYNCED_TO_SERVER
        for (var txn in pendingTxns) {
          txn.status = 'SYNCED_TO_SERVER';
          txn.save();
        }
        print('Successfully synced ${pendingTxns.length} transactions to server.');
      } else {
        print('Failed to sync transactions: Server responded with ${response.statusCode}');
      }
    } catch (e) {
      print('Sync error: $e');
    }
  }
}
