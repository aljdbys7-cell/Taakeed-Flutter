import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      ),
      home: const HomeScreen(),
    );
  }
}

class Transaction {
  final String amount;
  final String sender;
  final String wallet;
  final DateTime time;

  Transaction({required this.amount, required this.sender, required this.wallet, required this.time});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel('notification_listener');
  Transaction? _latestTx;
  List<Transaction> _history = [];
  final FlutterTts _tts = FlutterTts();
  String _currentTime = '';

  final Map<String, Color> walletColors = {
    'JAYB': const Color(0xFFD32F2F),
    'JAWALI': const Color(0xFFFF9800),
    'UMFULUS': const Color(0xFF9C27B0),
    'EASY': const Color(0xFFFFC107),
    'YEMEN_WALLET': const Color(0xFF4CAF50),
  };

  final Map<String, String> walletNames = {
    'JAYB': 'جيب',
    'JAWALI': 'جوالي',
    'UMFULUS': 'ام فلوس',
    'EASY': 'ايزي',
    'YEMEN_WALLET': 'يمن والت',
  };

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    _updateTime();
  }

  Future<void> _initPlatformState() async {
    platform.setMethodCallHandler((call) async {
      if (call.method == "onNewTransaction") {
        final data = Map<String, dynamic>.from(call.arguments);
        final tx = Transaction(
          amount: data['amount'],
          sender: data['sender'],
          wallet: data['wallet'],
          time: DateTime.now(),
        );
        setState(() {
          _latestTx = tx;
          _history = [tx,..._history.take(4)];
        });
        _playSound();
      }
    });
  }

  Future<void> _playSound() async {
    await _tts.setLanguage("ar-SA");
    await _tts.setSpeechRate(0.6);
    await _tts.speak("تم استلام مبلغ ${_latestTx?.amount} ريال");
  }

  void _updateTime() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final now = TimeOfDay.now();
        _currentTime = "${now.hour}:${now.minute.toString().padLeft(2,'0')}";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("متصل", style: TextStyle(color: Colors.green, fontSize: 14)),
                      Text("جميع الأنظمة تعمل", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ]),
                  ]),
                  Column(children: [
                    Text("تأكيد✓", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    Text("Taa'ked", style: TextStyle(color: Colors.white, fontSize: 12)),
                    Text("التحقق الفوري من الدفع", style: TextStyle(color: Colors.green, fontSize: 11)),
                  ]),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.white),
                    onPressed: () => platform.invokeMethod("openSettings"),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 12,
                      child: _latestTx == null
                       ? Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Center(child: Text("في انتظار إشعار دفع...", style: TextStyle(color: Colors.grey, fontSize: 18))),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: walletColors[_latestTx!.wallet]!, width: 3),
                              borderRadius: BorderRadius.circular(28),
                              color: walletColors[_latestTx!.wallet]!.withOpacity(0.12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("تم استلام مبلغ بنجاح", style: TextStyle(color: Colors.white, fontSize: 20)),
                                const SizedBox(height: 30),
                                Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Text("ر.ي", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 12),
                                  Text(_latestTx!.amount, style: TextStyle(color: Colors.white, fontSize: 70, fontWeight: FontWeight.w900)),
                                ]),
                                const SizedBox(height: 12),
                                Text("من / ${_latestTx!.sender}", style: TextStyle(color: walletColors[_latestTx!.wallet], fontSize: 18)),
                                const SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: walletColors[_latestTx!.wallet]!),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(walletNames[_latestTx!.wallet]!, style: TextStyle(color: walletColors[_latestTx!.wallet], fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("آخر 5 عمليات", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _history.length,
                              itemBuilder: (context, index) {
                                final tx = _history[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${tx.time.hour}:${tx.time.minute.toString().padLeft(2,'0')}:${tx.time.second.toString().padLeft(2,'0')}", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                        Text("${tx.amount} ر.ي", style: TextStyle(color: walletColors[tx.wallet], fontSize: 18, fontWeight: FontWeight.bold)),
                                        Text(tx.sender, style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ]),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_currentTime, style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text("جميع الأنظمة تعمل", style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
