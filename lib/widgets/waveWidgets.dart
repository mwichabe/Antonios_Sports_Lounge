import 'package:antonios/constants/color.dart';
import 'package:flutter/material.dart';
import 'dart:math' as Math;

import 'clipperWidgets.dart';


class WaveWidgets extends StatefulWidget {
  final size;
  final yOffset;
  final color;
  WaveWidgets({this.size, this.yOffset, this.color});

  @override
  State<WaveWidgets> createState() => _WaveWidgetsState();
}

class _WaveWidgetsState extends State<WaveWidgets> with TickerProviderStateMixin
{
  late AnimationController animationController;
  List<Offset> wavePoints = [];
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    animationController= AnimationController(vsync: this, duration: Duration(milliseconds: 8000))
      ..addListener(() {
        wavePoints.clear();
        final double waveSpeed = animationController.value*1800;
        final double fullSphere = animationController.value * Math.pi * 2;
        final double normalizer = Math.cos(fullSphere);
        final double waveWidth = Math.pi /270;
        final double waveHeight = 20.0;
        for(int i =0; i <= widget.size.width.toInt();++i)
        {
          double calc = Math.sin((waveSpeed-i)* waveWidth);
          wavePoints.add(
              Offset
                (
                i.toDouble(),
                calc * waveHeight*normalizer+widget.yOffset,
              )
          );
        }

      });
    animationController.repeat();
  }
  @override
  void dispose() {
    animationController.stop(canceled: true);
    animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:  animationController,
      builder: (context,_)
      {
        return ClipPath
          (
          clipper: ClipperWidget
            (
              waveList: wavePoints
          ),
          child: Container
            (
            width: widget.size.width,
            height: widget.size.height,
            color: AppColor.primaryColor,
          ),

        );
      },

    );
  }
}