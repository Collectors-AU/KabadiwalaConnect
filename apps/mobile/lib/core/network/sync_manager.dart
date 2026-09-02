import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../database/models/transaction_model.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final String apiEndpoint = 'http://10.0.2.2:8000/api/v1/sync'; // Adjust API host accordingly

  void initSyncListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      for (var result in results) {
        if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
          _syncPendingTransactions();
        }
      }
    });
  }

  Future<void> _syncPendingTransactions() async {
    try {
      final transactionsBox = Hive.box<TransactionModel>('transactionsBox');
      
      // Query LOCAL_PENDING transactions
      final pendingTxns = transactionsBox.values.where((txn) => txn.status == 'LOCAL_PENDING').toList();
      
      if (pendingTxns.isEmpty) return;

      final List<Map<String, dynamic>> payload = pendingTxns.map((txn) => {
        'txnId': txn.txnId,
        'lotId': txn.lotId,
        'collectorId': txn.collectorId,
        'finalWeightKg': txn.finalWeightKg,
        'ratePerKg': txn.ratePerKg,
        'totalPayoutInr': txn.totalPayoutInr,
        'paymentMode': txn.paymentMode,
      }).toList();

      final response = await http.post(
        Uri.parse(apiEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'transactions': payload}),
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
