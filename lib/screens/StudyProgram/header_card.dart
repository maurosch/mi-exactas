import 'package:flutter/material.dart';

class HeaderCard extends StatelessWidget {
  HeaderCard(
      {required this.average,
      required this.passed,
      required this.passedWithoutFinal,
      required this.amount,
      required this.title,
      required this.optativePoints,
      required this.amountOptativePoints});
  final num average,
      passed,
      amount,
      passedWithoutFinal,
      optativePoints,
      amountOptativePoints;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(children: [
            FittedBox(
                alignment: Alignment.bottomLeft,
                fit: BoxFit.scaleDown,
                child: Text(title,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ))),
            Divider(),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(width: 100),
                    Text(
                      "Tu Promedio",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(average.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.teal,
                        ))
                  ],
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Porcentaje",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          LinearProgressIndicator(
                              height: 13,
                              width: 120,
                              percentages: amount != 0
                                  ? [
                                      passed / amount,
                                      passedWithoutFinal / amount
                                    ]
                                  : [0, 0],
                              colors: [Colors.teal, Colors.purple[600]!],
                              backColor: Colors.grey),
                          SizedBox(width: 5),
                          Text(
                              amount != 0
                                  ? "${((passed + passedWithoutFinal) / amount * 100).toInt()}%"
                                  : "0",
                              style: TextStyle(
                                fontSize: 18,
                              )),
                        ],
                      ),
                    ]),
                Column(
                  children: <Widget>[
                    SizedBox(width: 100),
                    Text(
                      "Optativas",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text("$optativePoints/$amountOptativePoints",
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.teal,
                        ))
                  ],
                ),
              ],
            )
          ])),
    );
  }
}

class LinearProgressIndicator extends StatelessWidget {
  const LinearProgressIndicator(
      {required this.height,
      required this.percentages,
      required this.width,
      required this.colors,
      required this.backColor});
  final double height, width;
  final List<num> percentages;
  final List<Color> colors;
  final Color backColor;
  Widget build(BuildContext context) {
    num sumPercentages = percentages.reduce((a, b) => a + b);

    return ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(height * 2),
            topLeft: Radius.circular(height * 2),
            bottomRight: Radius.circular(height * 2),
            topRight: Radius.circular(height * 2)),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<int>.generate(percentages.length, (i) => i)
                    .map<Widget>(
                      (index) => Container(
                          height: height,
                          width: width * percentages[index],
                          color: colors[index]),
                    )
                    .toList() +
                [
                  Container(
                    height: height,
                    width: width * (1 - sumPercentages),
                    color: backColor,
                  ),
                ]));
  }
}
