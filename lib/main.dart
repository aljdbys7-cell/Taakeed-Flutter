import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة إعدادات التاريخ والوقت للغة العربية
  await initializeDateFormatting('ar', null);
  runApp(const TaakedApp());
}

class TaakedApp extends StatelessWidget {
  const TaakedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "تأكيد - Taa'ked",
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'), // دعم التوجيه العربي من اليمين لليسار
      ],
      // تطبيق سمة المظهر الداكن مع استخدام خط Cairo الموصى به للمظهر العريض
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0E15),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MainDashboard(),
    );
  }
}

// نموذج بيانات العمليات اللحظية
class PaymentTransaction {
  final String amount;
  final String sender;
  final String time;
  final String walletName;
  final Color themeColor;
  final IconData icon;

  PaymentTransaction({
    required this.amount,
    required this.sender,
    required this.time,
    required this.walletName,
    required this.themeColor,
    required this.icon,
  });
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  String _currentTime = "";
  String _currentDate = "";
  Timer? _clockTimer;
  Timer? _notificationTimer;

  late PaymentTransaction _currentPayment;
  List<PaymentTransaction> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateClock());

    // البيانات الافتراضية الأولية المطابقة للواجهة الأصلية
    _currentPayment = PaymentTransaction(
      amount: "2,500",
      sender: "محمد إسماعيل",
      time: "12:30:15",
      walletName: "جيب",
      themeColor: const Color(0xFF7A0A14),
      icon: Icons.account_balance_wallet_rounded,
    );

    _recentTransactions = [
      PaymentTransaction(amount: "2,500", sender: "محمد إسماعيل", time: "12:30:15", walletName: "جيب", themeColor: const Color(0xFF7A0A14), icon: Icons.account_balance_wallet),
      PaymentTransaction(amount: "1,200", sender: "خالد أحمد", time: "12:28:02", walletName: "جوالي", themeColor: const Color(0xFF1E105A), icon: Icons.phone_android),
      PaymentTransaction(amount: "3,750", sender: "علي حسن", time: "12:25:47", walletName: "ون كاش", themeColor: const Color(0xFF5A350A), icon: Icons.money),
    ];

    // تشغيل محاكي الإشعارات اللحظية كل 15 ثانية للتجربة الديناميكية وتغيير ألوان المراية
    _startReceiptSimulation();
  }

  void _updateClock() {
    final DateTime now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('hh:mm:ss a', 'en_US').format(now); 
      _currentDate = DateFormat('EEEE، d مايو yyyy', 'ar').format(now); 
    });
  }

  void _onNewReceipt(PaymentTransaction newTx) {
    setState(() {
      _currentPayment = newTx;
      _recentTransactions.insert(0, newTx);
      if (_recentTransactions.length > 5) _recentTransactions.removeLast();
    });
  }

  void _startReceiptSimulation() {
    List<PaymentTransaction> pool = [
      PaymentTransaction(amount: "850", sender: "أحمد عبدالله", time: "05:51:39", walletName: "ون كاش", themeColor: const Color(0xFFc2410c), icon: Icons.money),
      PaymentTransaction(amount: "5,000", sender: "أحمد صالح العمري", time: "06:12:00", walletName: "جوالي", themeColor: const Color(0xFF1E105A), icon: Icons.phone_android),
      PaymentTransaction(amount: "1,500", sender: "حسين عبدالله", time: "06:15:40", walletName: "جيب", themeColor: const Color(0xFF7A0A14), icon: Icons.account_balance_wallet_rounded),
    ];
    int i = 0;
    _notificationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      final now = DateTime.now();
      _onNewReceipt(PaymentTransaction(
        amount: pool[i % pool.length].amount,
        sender: pool[i % pool.length].sender,
        time: DateFormat('hh:mm:ss', 'en_US').format(now),
        walletName: pool[i % pool.length].walletName,
        themeColor: pool[i % pool.length].themeColor,
        icon: pool[i % pool.length].icon,
      ));
      i++;
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // شاشة تلفزيون ذكي أو متصفح ويب عريض
            if (constraints.maxWidth > 900) {
              return _buildHorizontalTVLayout();
            } 
            // شاشة عرضية وسطى (الأجهزة اللوحية كالأيباد بوضع عمودي)
            else if (constraints.maxWidth > 650) {
              return _buildHorizontalTVLayout();
            }
            // شاشة الهاتف المحمول بوضع عمودي متجاوب
            else {
              return _buildVerticalMobileLayout();
            }
          },
        ),
      ),
    );
  }

  // --- واجهة شاشات التلفزيون والأجهزة اللوحية (أفقي) ---
  Widget _buildHorizontalTVLayout() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildHeader(isMobile: false),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: _buildLiveMirror()),
                const SizedBox(width: 20),
                Expanded(flex: 1, child: _buildRecentTransactionsSection()),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildFooter(isMobile: false),
        ],
      ),
    );
  }

  // --- واجهة شاشات الهواتف المحمولة (عمودي) ---
  Widget _buildVerticalMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(isMobile: true),
            const SizedBox(height: 16),
            SizedBox(height: 400, child: _buildLiveMirror()),
            const SizedBox(height: 16),
            SizedBox(height: 350, child: _buildRecentTransactionsSection()),
            const SizedBox(height: 16),
            _buildFooter(isMobile: true),
          ],
        ),
      ),
    );
  }

  // 1. شريط العنوان والأنظمة العلوي
  Widget _buildHeader({required bool isMobile}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!isMobile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.emerald.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.emerald.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi, color: Colors.emerald, size: 18),
                SizedBox(width: 8),
                Text("متصل \nجميع الأنظمة تعمل بشكل جيد", style: TextStyle(color: Colors.emerald, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        Column(
          children: [
            const Text("تأكـ✓ـيد", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
            if (!isMobile) ...[
              const Text("Taa'ked", style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 4),
              const Text("التحقق الفوري من الدفع | Instant Payment Validation", style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
            ]
          ],
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.settings, color: Colors.white70, size: 18),
          label: const Text("الإعدادات", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  // 2. شاشة المراية المركزية (تحديث فوري للخلفيات والأيقونات مع كل إشعار)
  Widget _buildLiveMirror() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _currentPayment.themeColor.withOpacity(0.8),
            const Color(0xFF131520),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _currentPayment.themeColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: _currentPayment.themeColor.withOpacity(0.15), blurRadius: 40, spreadRadius: 5)
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -40, top: -40,
            child: Icon(_currentPayment.icon, size: 250, color: Colors.white.withOpacity(0.03)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 35, backgroundColor: Colors.white,
                child: Icon(_currentPayment.icon, size: 40, color: _currentPayment.themeColor),
              ),
              const SizedBox(height: 8),
              Text("محفظة ${_currentPayment.walletName}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("تم استلام مبلغ بنجاح", style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.normal)),
                  SizedBox(width: 8),
                  Icon(Icons.check_circle, color: Colors.greenAccent, size: 26),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(_currentPayment.amount, style: const TextStyle(fontSize: 65, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 8),
                  const Text("ر.ي", style: TextStyle(fontSize: 24, color: Colors.white70, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Text("من / ${_currentPayment.sender}", style: const TextStyle(fontSize: 20, color: Colors.white90)),
            ],
          ),
        ],
      ),
    );
  }

  // 3. قائمة السجل الجانبي لآخر 5 عمليات دفع مستلمة
  Widget _buildRecentTransactionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131520),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("آخر العمليات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.history, color: Colors.white54, size: 22),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _recentTransactions.length,
              itemBuilder: (context, index) {
                final tx = _recentTransactions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: tx.themeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: tx.themeColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(tx.amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                              const SizedBox(width: 4),
                              const Text("ر.ي", style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text("من ${tx.sender}", style: const TextStyle(fontSize: 13, color: Colors.white70)),
                          const SizedBox(height: 2),
                          Text(tx.time, style: const TextStyle(fontSize: 10, color: Colors.white38)),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white, radius: 20,
                        child: Icon(tx.icon, size: 22, color: tx.themeColor),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 4. الشريط السفلي المحدث (يحتوي فقط على الوقت والتاريخ الحالي ونص الأمان)
  Widget _buildFooter({required bool isMobile}) {
    final clockWidget = Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(_currentTime.isEmpty ? "12:30:15 PM" : _currentTime, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        Text(_currentDate.isEmpty ? "الأحد، 31 مايو 2026" : _currentDate, style: const TextStyle(fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w600)),
      ],
    );

    if (isMobile) {
      return Center(
        child: clockWidget,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        clockWidget,
        const Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.emerald, size: 22),
            SizedBox(width: 8),
            Text("التطبيق يعمل في بيئة آمنة ومشفرة بالكامل", style: TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ],
    );
  }
}
