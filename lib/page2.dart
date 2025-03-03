import 'package:flutter/material.dart';
import 'package:puff_free/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _dailyPuffs = 0;
  int _weeklyPuffs = 0;
  int _monthlyPuffs = 0;
  final List<Map<String, dynamic>> _last7DaysData = [];
  final List<Map<String, dynamic>> _last30DaysData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPuffData();
  }

  Future<void> _loadPuffData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _dailyPuffs = prefs.getInt(_getDateKey(DateTime.now())) ?? 0;
    _weeklyPuffs = _loadRecentData(prefs, 7, _last7DaysData);
    _monthlyPuffs = _loadRecentData(prefs, 30, _last30DaysData);

    setState(() {});
  }

  int _loadRecentData(
      SharedPreferences prefs, int days, List<Map<String, dynamic>> storage) {
    int totalPuffs = 0;
    storage.clear();

    for (int i = 0; i < days; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      String key = _getDateKey(date);
      int puffs = prefs.getInt(key) ?? 0;
      storage.add({'date': date, 'puffs': puffs});
      totalPuffs += puffs;
    }

    return totalPuffs;
  }

  String _getDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDayTab(),
                  _buildWeekTab(),
                  _buildMonthTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Usage Monitor',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        fontFamily: 'Nunito',
        color: kPrimaryColor,
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: kPrimaryColor,
      unselectedLabelColor: Colors.black54,
      indicatorColor: kPrimaryColor,
      tabs: const [
        Tab(text: 'Day'),
        Tab(text: 'Week'),
        Tab(text: 'Month'),
      ],
    );
  }

  Widget _buildDayTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Puffs Today',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$_dailyPuffs puffs',
            style: const TextStyle(
              fontSize: 32,
              fontFamily: 'Nunito',
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekTab() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Total Weekly Puffs: $_weeklyPuffs',
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LineChart(_buildChartData(_last7DaysData, isWeek: true)),
        ),
      ],
    );
  }

  Widget _buildMonthTab() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Total Monthly Puffs: $_monthlyPuffs',
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LineChart(_buildChartData(_last30DaysData, isWeek: false)),
        ),
      ],
    );
  }

  LineChartData _buildChartData(List<Map<String, dynamic>> data,
      {required isWeek}) {
    final maxY = data.isNotEmpty
        ? data
            .map((e) => e['puffs'] as int)
            .reduce((a, b) => a > b ? a : b)
            .toDouble()
        : 10;

    final paddedMaxY = maxY > 0 ? maxY + (maxY * 0.2) : 10; // Prevent zero maxY

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval:
            paddedMaxY / 5, // Adjust grid lines based on padded maxY
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.2),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: paddedMaxY / 5,
            getTitlesWidget: (value, meta) {
              if (value < 0)
                return const SizedBox.shrink(); // Hide negative labels
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              );
            },
            reservedSize: 40,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: isWeek ? 1 : 6, // Show every 7 days
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < data.length) {
                DateTime date = data[index]['date'];
                return Text(
                  DateFormat('MMM d').format(date), // Format as "Feb 9"
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                );
              }
              return const SizedBox.shrink();
            },

            reservedSize: 32, // Space for bottom titles
          ),
        ),
        topTitles: const AxisTitles(
          // Hide top titles
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          // Hide right titles
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      minX: 0,
      maxX: data.length > 1 ? (data.length - 1).toDouble() : 1,
      minY: -6,
      maxY: double.parse(paddedMaxY.toStringAsFixed(0)),
      lineBarsData: [
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .map((entry) => FlSpot(
                    entry.key.toDouble(),
                    entry.value['puffs'].toDouble(),
                  ))
              .toList(),
          isCurved: true,
          barWidth: 4,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(
            show: true, // Fill the area below the line
          ),
          dotData: const FlDotData(show: false), // Hide dots for cleaner look
        ),
      ],
    );
  }
}
