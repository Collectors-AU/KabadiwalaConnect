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

  static const String SERVER_HOST = "192.168.1.35";
  final String apiEndpoint = "http://$SERVER_HOST:8000/api/v1/sync";

  void initSyncListener() {
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

  Future<void> processOutboxQueue() async {
    try {
      final dynamic connectivityResult = await Connectivity().checkConnectivity();
      bool hasConnection = false;
      
      if (connectivityResult is List) {
        hasConnection = connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi);
      } else {
        hasConnection = connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi;
      }
      
      if (!hasConnection) return;

      final transactionsBox = Hive.box<TransactionModel>('transactionsBox');
      final traceBox = Hive.box<TraceabilityModel>('traceabilityBox');
      
      // Filter LOCAL_PENDING transactions
      final pendingTxns = transactionsBox.values.where((txn) => txn.status == 'LOCAL_PENDING').toList();
      
      if (pendingTxns.isEmpty) return;

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
      ).timeout(const Duration(seconds: 8));

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
        print('Successfully synced $successCount transactions to server.');
      } else {
        print('Failed to sync transactions: Server responded with ${response.statusCode}');
      }
    } catch (e) {
      print('Sync error: $e');
    }
  }
}
