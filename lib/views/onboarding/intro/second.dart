import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Assets
import 'package:Tether/global/assets.dart';

class SecondSection extends StatelessWidget {
  SecondSection({Key key, this.title}) : super(key: key);

  final String title;
  final double DEFAULT_INPUT_HEIGHT = 52;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(height: height * 0.05),
        Container(
          width: width * 0.7,
          height: DEFAULT_INPUT_HEIGHT,
          constraints:
              BoxConstraints(minWidth: 200, maxWidth: 400, minHeight: 200),
          child: SvgPicture.asset(CONNECTION_GRAPHIC,
              semanticsLabel: 'Two people messaging privately but leisurely'),
        ),
        SizedBox(height: height * 0.04),
        Text(
          'Matrix allows you to message others \nprivately but you control where \nyour messages are stored',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle,
        ),
        SizedBox(height: height * 0.025),
      ],
    ));
  }
}
