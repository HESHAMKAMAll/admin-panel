import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

class Chart extends StatelessWidget {
  const Chart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: paiChartSelectionDatas,
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: Constants.kPadding),
                Text(
                  "29.1",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 0.5,
                  ),
                ),
                Text("of 128GB")
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<PieChartSectionData> paiChartSelectionDatas = [
  PieChartSectionData(
    color: Constants.purpleLight,
    value: 25,
    showTitle: false,
    radius: 25,
  ),
  PieChartSectionData(
    color: Color(0xFF26E5FF),
    value: 20,
    showTitle: false,
    radius: 22,
  ),
  PieChartSectionData(
    color: Color(0xFFFFCF26),
    value: 10,
    showTitle: false,
    radius: 19,
  ),
  PieChartSectionData(
    color: Color(0xFFEE2727),
    value: 15,
    showTitle: false,
    radius: 16,
  ),
  PieChartSectionData(
    color: Constants.orange,
    value: 25,
    showTitle: false,
    radius: 13,
  ),
];

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State {
  int touchedIndex = -1;

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: Constants.kPadding / 2,
          bottom: Constants.kPadding,
          right: Constants.kPadding / 2),
      child: Card(
        color: Constants.purpleLight,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(
              height: 18,
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                        setState(() {
                          if (response == null || response.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }

                          // Check if it's a tap down or move event
                          if (event is FlTapDownEvent || event is FlPanUpdateEvent) {
                            touchedIndex = response.touchedSection!.touchedSectionIndex;
                          } else {
                            touchedIndex = -1;
                          }
                        });
                      },
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: showingSections(),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Indicator(
                  color: Color(0xff0293ee),
                  text: 'First',
                  isSquare: true,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Color(0xfff8b250),
                  text: 'Second',
                  isSquare: true,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Color(0xffff5182),
                  text: 'Third',
                  isSquare: true,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Color(0xff13d38e),
                  text: 'Fourth',
                  isSquare: true,
                ),
                SizedBox(
                  height: 18,
                ),
              ],
            ),
            const SizedBox(
              width: 28,
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xffff5182),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        )
      ],
    );
  }
}

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  _LineChartSample2State createState() => _LineChartSample2State();
}
class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: Constants.kPadding / 2,
          top: Constants.kPadding,
          bottom: Constants.kPadding,
          right: Constants.kPadding / 2),
      child: Card(
        color: Constants.purpleLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
        child: Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(18),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 18.0, left: 12.0, top: 24, bottom: 12),
                  child: LineChart(
                    showAvg ? avgData() : mainData(),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              height: 34,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showAvg = !showAvg;
                  });
                },
                child: Text(
                  'avg',
                  style: TextStyle(
                      fontSize: 12,
                      color: showAvg
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff68737d),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              );
              String text;
              switch (value.toInt()) {
                case 2:
                  text = 'MAR';
                  break;
                case 5:
                  text = 'JUN';
                  break;
                case 8:
                  text = 'SEP';
                  break;
                default:
                  text = '';
                  break;
              }
              return Text(text, style: style);
            },
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff67727d),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              );
              String text;
              switch (value.toInt()) {
                case 1:
                  text = '10k';
                  break;
                case 3:
                  text = '30k';
                  break;
                case 5:
                  text = '50k';
                  break;
                default:
                  text = '';
                  break;
              }
              return Text(text, style: style);
            },
            reservedSize: 28,
            interval: 1,
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
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2.6, 2),
            FlSpot(4.9, 5),
            FlSpot(6.8, 3.1),
            FlSpot(8, 4),
            FlSpot(9.5, 3),
            FlSpot(11, 4),
          ],
          isCurved: true,
          color: gradientColors[0],
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withValues(alpha: 0.3))
                  .toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff68737d),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              );
              String text;
              switch (value.toInt()) {
                case 2:
                  text = 'MAR';
                  break;
                case 5:
                  text = 'JUN';
                  break;
                case 8:
                  text = 'SEP';
                  break;
                default:
                  text = '';
                  break;
              }
              return Text(text, style: style);
            },
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff67727d),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              );
              String text;
              switch (value.toInt()) {
                case 1:
                  text = '10k';
                  break;
                case 3:
                  text = '30k';
                  break;
                case 5:
                  text = '50k';
                  break;
                default:
                  text = '';
                  break;
              }
              return Text(text, style: style);
            },
            reservedSize: 28,
            interval: 1,
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
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          color: ColorTween(begin: gradientColors[0], end: gradientColors[1])
              .lerp(0.2),
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withValues(alpha: 0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withValues(alpha: 0.1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }
}

class LineChartSample1 extends StatefulWidget {
  const LineChartSample1({super.key});

  @override
  State<StatefulWidget> createState() => LineChartSample1State();
}
class LineChartSample1State extends State<LineChartSample1> {
  late bool isShowingMainData;

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          right: Constants.kPadding / 2,
          top: Constants.kPadding,
          left: Constants.kPadding / 2),
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          color: Constants.purpleLight,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 3,
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(
                    height: 37,
                  ),
                  const Text(
                    'Unfold Shop 2021',
                    style: TextStyle(
                      color: Color(0xff827daa),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  const Text(
                    'Monthly Sales',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 37,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                      child: LineChart(
                        isShowingMainData ? sampleData1() : sampleData2(),
                        duration: const Duration(milliseconds: 250),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color:
                  Colors.white.withOpacity(isShowingMainData ? 1.0 : 0.5),
                ),
                onPressed: () {
                  setState(() {
                    isShowingMainData = !isShowingMainData;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  LineChartData sampleData1() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          // tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
        handleBuiltInTouches: true,
      ),
      gridData: const FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: 1,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff72719b),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              );
              String text;
              switch (value.toInt()) {
                case 2:
                  text = 'SEPT';
                  break;
                case 7:
                  text = 'OCT';
                  break;
                case 12:
                  text = 'DEC';
                  break;
                default:
                  text = '';
                  break;
              }
              return Text(text, style: style);
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff75729e),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              );
              String text;
              switch (value.toInt()) {
                case 1:
                  text = '1m';
                  break;
                case 2:
                  text = '2m';
                  break;
                case 3:
                  text = '3m';
                  break;
                case 4:
                  text = '5m';
                  break;
                default:
                  text = '';
                  break;
              }
              return Text(text, style: style, textAlign: TextAlign.center);
            },
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
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 4,
          ),
          left: BorderSide(
            color: Colors.transparent,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      minX: 0,
      maxX: 14,
      maxY: 4,
      minY: 0,
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    final lineChartBarData1 = LineChartBarData(
      spots: const [
        FlSpot(1, 1),
        FlSpot(3, 1.5),
        FlSpot(5, 1.4),
        FlSpot(7, 3.4),
        FlSpot(10, 2),
        FlSpot(12, 2.2),
        FlSpot(13, 1.8),
      ],
      isCurved: true,
      color: const Color(0xff4af699),
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: const FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    final lineChartBarData2 = LineChartBarData(
      spots: const [
        FlSpot(1, 1),
        FlSpot(3, 2.8),
        FlSpot(7, 1.2),
        FlSpot(10, 2.8),
        FlSpot(12, 2.6),
        FlSpot(13, 3.9),
      ],
      isCurved: true,
      color: const Color(0xffff5182),
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: const FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    final lineChartBarData3 = LineChartBarData(
      spots: const [
        FlSpot(1, 2.8),
        FlSpot(3, 1.9),
        FlSpot(6, 3),
        FlSpot(10, 1.3),
        FlSpot(13, 2.5),
      ],
      isCurved: true,
      color: const Color(0xfff8b250),
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: const FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    return [
      lineChartBarData1,
      lineChartBarData2,
      lineChartBarData3,
    ];
  }

  LineChartData sampleData2() {
    return LineChartData(
      lineTouchData: const LineTouchData(
        enabled: false,
      ),
      gridData: const FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: 1,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff72719b),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              );
              String text;
              switch (value.toInt()) {
                case 2:
                  text = 'SEPT';
                  break;
                case 7:
                  text = 'OCT';
                  break;
                case 12:
                  text = 'DEC';
                  break;
                default:
                  text = '';
                  break;
              }
              return Text(text, style: style);
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                color: Color(0xff75729e),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              );
              String text;
              switch (value.toInt()) {
                case 1:
                  text = '1m';
                  break;
                case 2:
                  text = '2m';
                  break;
                case 3:
                  text = '3m';
                  break;
                case 4:
                  text = '5m';
                  break;
                case 5:
                  text = '6m';
                  break;
                default:
                  text = '';
                  break;
              }
              return Text(text, style: style, textAlign: TextAlign.center);
            },
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
          border: const Border(
            bottom: BorderSide(
              color: Color(0xff4e4965),
              width: 4,
            ),
            left: BorderSide(
              color: Colors.transparent,
            ),
            right: BorderSide(
              color: Colors.transparent,
            ),
            top: BorderSide(
              color: Colors.transparent,
            ),
          )),
      minX: 0,
      maxX: 14,
      maxY: 6,
      minY: 0,
      lineBarsData: linesBarData2(),
    );
  }

  List<LineChartBarData> linesBarData2() {
    return [
      LineChartBarData(
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 4),
          FlSpot(5, 1.8),
          FlSpot(7, 5),
          FlSpot(10, 2),
          FlSpot(12, 2.2),
          FlSpot(13, 1.8),
        ],
        isCurved: true,
        curveSmoothness: 0,
        color: const Color(0x444af699),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
      LineChartBarData(
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 2.8),
          FlSpot(7, 1.2),
          FlSpot(10, 2.8),
          FlSpot(12, 2.6),
          FlSpot(13, 3.9),
        ],
        isCurved: true,
        color: const Color(0x99aa4cfc),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          color: const Color(0x33aa4cfc),
        ),
      ),
      LineChartBarData(
        spots: const [
          FlSpot(1, 3.8),
          FlSpot(3, 1.9),
          FlSpot(6, 5),
          FlSpot(10, 3.3),
          FlSpot(13, 4.5),
        ],
        isCurved: true,
        curveSmoothness: 0,
        color: const Color(0x4427b6fc),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
    ];
  }
}

class BarChartSample2 extends StatefulWidget {
  const BarChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => BarChartSample2State();
}
class BarChartSample2State extends State<BarChartSample2> {
  final Color leftBarColor = const Color(0xff53fdd7);
  final Color rightBarColor = const Color(0xffff5182);
  final double width = 7;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    final barGroup1 = makeGroupData(0, 5, 12);
    final barGroup2 = makeGroupData(1, 16, 12);
    final barGroup3 = makeGroupData(2, 18, 5);
    final barGroup4 = makeGroupData(3, 20, 16);
    final barGroup5 = makeGroupData(4, 17, 6);
    final barGroup6 = makeGroupData(5, 19, 1.5);
    final barGroup7 = makeGroupData(6, 10, 1.5);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];

    rawBarGroups = items;
    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: Constants.kPadding,
          left: Constants.kPadding / 2,
          right: Constants.kPadding / 2),
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          color: Constants.purpleLight,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 3,
          //Color(0xff232d37), //const Color(0xff2c4260),),
          child: Padding(
            padding: const EdgeInsets.all(Constants.kPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    //makeTransactionsIcon(),
                    const Text(
                      'Monthly Profits',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const Text(
                      r'$345,462',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Of ',
                      style: TextStyle(color: Color(0xff77839a), fontSize: 16),
                    ),
                    Text(
                      'Sales ',
                      style: TextStyle(color: leftBarColor, fontSize: 16),
                    ),
                    const Text(
                      'And ',
                      style: TextStyle(color: Color(0xff77839a), fontSize: 16),
                    ),
                    Text(
                      'Orders',
                      style: TextStyle(color: rightBarColor, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 38,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: BarChart(
                      BarChartData(
                        maxY: 20,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => Colors.grey,
                            getTooltipItem: (_a, _b, _c, _d) => null,
                          ),
                          touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                            if (response == null || response.spot == null) {
                              setState(() {
                                touchedGroupIndex = -1;
                                showingBarGroups = List.of(rawBarGroups);
                              });
                              return;
                            }

                            touchedGroupIndex = response.spot!.touchedBarGroupIndex;

                            setState(() {
                              if (event is FlPanEndEvent || event is FlTapUpEvent) {
                                touchedGroupIndex = -1;
                                showingBarGroups = List.of(rawBarGroups);
                              } else {
                                showingBarGroups = List.of(rawBarGroups);
                                if (touchedGroupIndex != -1) {
                                  var sum = 0.0;
                                  for (var rod in showingBarGroups[touchedGroupIndex].barRods) {
                                    sum += rod.toY;
                                  }
                                  final avg = sum / showingBarGroups[touchedGroupIndex].barRods.length;

                                  showingBarGroups[touchedGroupIndex] =
                                      showingBarGroups[touchedGroupIndex].copyWith(
                                        barRods: showingBarGroups[touchedGroupIndex].barRods.map((rod) {
                                          return rod.copyWith(toY: avg);
                                        }).toList(),
                                      );
                                }
                              }
                            });
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                String text;
                                switch (value.toInt()) {
                                  case 0:
                                    text = 'Mn';
                                    break;
                                  case 1:
                                    text = 'Te';
                                    break;
                                  case 2:
                                    text = 'Wd';
                                    break;
                                  case 3:
                                    text = 'Tu';
                                    break;
                                  case 4:
                                    text = 'Fr';
                                    break;
                                  case 5:
                                    text = 'St';
                                    break;
                                  case 6:
                                    text = 'Sn';
                                    break;
                                  default:
                                    text = '';
                                    break;
                                }
                                return Text(
                                  text,
                                  style: const TextStyle(
                                    color: Color(0xff7589a2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                              reservedSize: 38,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                String text;
                                if (value == 0) {
                                  text = '1K';
                                } else if (value == 10) {
                                  text = '5K';
                                } else if (value == 19) {
                                  text = '10K';
                                } else {
                                  return Container();
                                }
                                return Text(
                                  text,
                                  style: const TextStyle(
                                    color: Color(0xff7589a2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.left,
                                );
                              },
                              reservedSize: 32,
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
                          show: false,
                        ),
                        barGroups: showingBarGroups,
                        gridData: const FlGridData(show: false),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: leftBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: rightBarColor,
          width: width,
        ),
      ],
    );
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withValues(alpha: 0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withValues(alpha: 0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withValues(alpha: 1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withValues(alpha: 0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }
}
