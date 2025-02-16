import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puff_free/const.dart';

class HomeFlChart extends StatefulWidget {
  final List<DateTime> puffTimestamps; // Accept puffTimestamps dynamically

  const HomeFlChart({super.key, required this.puffTimestamps});

  @override
  State<HomeFlChart> createState() => _HomeFlChartState();
}

class _HomeFlChartState extends State<HomeFlChart> {
  List<Color> gradientColors = [kPrimaryColor, Colors.black];
  bool showAvg = false;

  @override
  void initState() {
    super.initState();
    _loadPuffData(); // Load puff data when the widget is initialized
  }

  // Method to load puff data from SharedPreferences
  Future<void> _loadPuffData() async {
    final prefs = await SharedPreferences.getInstance();
    final puffTimestampsStr = prefs.getStringList('puff_timestamps');
    if (puffTimestampsStr != null) {
      setState(() {
        widget.puffTimestamps
            .addAll(puffTimestampsStr.map((e) => DateTime.parse(e)).toList());
      });
    }
  }

  // Method to save puff data to SharedPreferences
  Future<void> _savePuffData(List<DateTime> puffTimestamps) async {
    final prefs = await SharedPreferences.getInstance();
    final puffTimestampsStr =
        puffTimestamps.map((e) => e.toIso8601String()).toList();
    await prefs.setStringList('puff_timestamps', puffTimestampsStr);
  }

  // Method to clear puff data from SharedPreferences
  Future<void> _clearPuffData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('puff_timestamps');
  }

  // Calculate puff distribution for the different parts of the day
  Map<String, int> calculatePuffDistribution() {
    int morning = 0;
    int afternoon = 0;
    int evening = 0;
    int night = 0;

    // Define time ranges for the parts of the day
    DateTime morningStart = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 6, 0);
    DateTime afternoonStart = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0);
    DateTime eveningStart = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 18, 0);
    DateTime nightStart = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 21, 0);

    // Loop through puffTimestamps and categorize puffs
    for (var timestamp in widget.puffTimestamps) {
      if (timestamp.isAfter(morningStart) &&
          timestamp.isBefore(afternoonStart)) {
        morning++;
      } else if (timestamp.isAfter(afternoonStart) &&
          timestamp.isBefore(eveningStart)) {
        afternoon++;
      } else if (timestamp.isAfter(eveningStart) &&
          timestamp.isBefore(nightStart)) {
        evening++;
      } else if (timestamp.isAfter(nightStart)) {
        night++;
      }
    }

    return {
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
      'night': night,
    };
  }

  @override
  Widget build(BuildContext context) {
    final puffDistribution = calculatePuffDistribution();

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(puffDistribution),
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: SizedBox(
            width: 60,
            height: 34,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showAvg = !showAvg;
                });
              },
              child: Text(
                'Avg',
                style: TextStyle(
                  fontSize: 12,
                  color: showAvg ? Colors.white : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;

    // Dynamic x-axis labels
    switch (value.toInt()) {
      case 0:
        text = const Text('Morning', style: style);
        break;
      case 1:
        text = const Text('Afternoon', style: style);
        break;
      case 2:
        text = const Text('Evening', style: style);
        break;
      case 3:
        text = const Text('Night', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    return Text('${value.toInt()}', style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData(Map<String, int> puffDistribution) {
    final data = [
      puffDistribution['morning']?.toDouble() ?? 0.0,
      puffDistribution['afternoon']?.toDouble() ?? 0.0,
      puffDistribution['evening']?.toDouble() ?? 0.0,
      puffDistribution['night']?.toDouble() ?? 0.0,
    ];

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 5,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 0.5,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 0.5,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 30,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 3, // 4 parts of the day
      minY: 0,
      maxY: widget.puffTimestamps.length.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            data.length,
            (index) => FlSpot(index.toDouble(), data[index]),
          ),
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 2,
        verticalInterval: 1,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 30,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 3, // 4 parts of the day
      minY: 0,
      maxY: widget.puffTimestamps.length.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 4),
            FlSpot(1, 4),
            FlSpot(2, 4),
            FlSpot(3, 4),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              kPrimaryColor.withOpacity(0.5),
              Colors.black.withOpacity(0.5),
            ],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                kPrimaryColor.withOpacity(0.2),
                Colors.black.withOpacity(0.2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Reset puff data when daily puff limit is empty
  Future<void> _resetPuffData() async {
    await _clearPuffData();
    setState(() {
      widget.puffTimestamps.clear();
    });
  }
}
