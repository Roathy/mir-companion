import 'package:flutter/material.dart';
import 'package:kg_charts/kg_charts.dart';

import '../data/datasource/skill_list.dart';

class RadarChart extends StatelessWidget {
  const RadarChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RadarWidget(
        radarMap: RadarMapModel(
          legend: skillList.map((skill) => LegendModel('10/10', skill.color)).toList(),
          indicator: skillList.map((skill) => IndicatorModel(skill.title, skill.maxScore)).toList(),
          data: [
            MapDataModel([
              100,
              90,
              100,
              60,
              70,
            ]),
            MapDataModel([
              50,
              90,
              90,
              10,
              15,
            ]),
            MapDataModel([
              0,
              0,
              0,
              0,
              0,
            ]),
            MapDataModel([
              0,
              0,
              0,
              0,
              0,
            ]),
            MapDataModel([
              0,
              0,
              0,
              0,
              0,
            ]),
          ],
          radius: 90,
          duration: 2000,
          shape: Shape.square,
          maxWidth: 70,
          line: LineModel(5),
        ),
        textStyle: const TextStyle(color: Colors.black87, fontSize: 12),
        isNeedDrawLegend: true,
        lineText: (p, length) => "${(p * 100 ~/ length)}%",
        dilogText: (IndicatorModel indicatorModel, List<LegendModel> legendModels, List<double> mapDataModels) {
          StringBuffer text = StringBuffer("");
          for (int i = 0; i < mapDataModels.length; i++) {
            text.write("${legendModels[i].name} : ${mapDataModels[i].toString()}");
            if (i != mapDataModels.length - 1) {
              text.write("\n");
            }
          }
          return text.toString();
        },
        outLineText: (data, max) => "${data * 100 ~/ max}%");
  }
}
