library lamp_bottom_navigation;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LampBottomNavigationBar extends StatefulWidget {
  final double width;
  final List<Widget> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final Color dashColor;
  final Color lightColor;

  LampBottomNavigationBar({
    this.items = const <Widget>[],
    this.width,
    this.onTap,
    this.currentIndex = 0,
    Color backgroundColor,
    Color dashColor,
    Color lightColor,
  })  : this.backgroundColor = backgroundColor ?? Colors.grey[800],
        this.dashColor = dashColor ?? Colors.white,
        this.lightColor = lightColor ?? Colors.white;

  @override
  _LampBottomNavigationBarState createState() =>
      _LampBottomNavigationBarState();
}

class _LampBottomNavigationBarState extends State<LampBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  int oldIndex = 0;
  AnimationController _controller;
  double width;

  @override
  initState() {
    super.initState();
    _resetState();
  }

  _resetState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
      reverseDuration: Duration(milliseconds: 400),
    );
    _controller.forward();
    width = widget.width ?? MediaQuery.of(context).size.width;
  }

  _buildNavigationTile() {
    var tiles = <Widget>[];
    for (int i = 0; i < widget.items.length; i++) {
      tiles.add(
        InkWell(
          onTap: () {
            if (widget.onTap != null) widget.onTap(i);
          },
          child: LampNavigationBarTile(
            key: UniqueKey(),
            icon: widget.items[i],
            active: i == widget.currentIndex,
            wasActive: i == oldIndex,
            animation: _controller,
            lightColor: widget.lightColor,
          ),
        ),
      );
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: 56,
        width: width,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
        ),
        child: Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: _controller,
              builder: (_, w) {
                return Container(
                  height: 56,
                  width: width,
                  child: CustomPaint(
                    foregroundPainter: _SelectedTilePainter(
                      newPosition: widget.currentIndex,
                      oldPosition: oldIndex,
                      color: widget.dashColor,
                      progress: Tween<double>(begin: 0.0, end: 1.0)
                          .animate(CurvedAnimation(
                              parent: _controller,
                              curve:
                                  Interval(0.0, 0.5, curve: Curves.easeInOut)))
                          .value,
                      count: widget.items.length,
                    ),
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[..._buildNavigationTile()],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class LampNavigationBarTile extends StatelessWidget {
  final Widget icon;
  final bool active, wasActive;
  final double iconSize;
  final Animation animation;
  final VoidCallback onTap;
  final Color lightColor;

  LampNavigationBarTile({
    Key key,
    @required this.icon,
    @required this.animation,
    this.iconSize = 24,
    this.onTap,
    this.active = false,
    this.wasActive = false,
    this.lightColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: iconSize + 24,
      child: Stack(
        children: <Widget>[
          Center(
            child: icon,
          ),
          FadeTransition(
            opacity: ((active)
                ? Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Interval(
                        0.6,
                        1,
                        curve: Curves.easeInOut,
                      ),
                    ),
                  )
                : Tween<double>(begin: 1, end: 0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Interval(
                        0,
                        0.4,
                        curve: Curves.easeInOut,
                      ),
                    ),
                  )),
            child: CustomPaint(
              foregroundPainter: _LightLampPainter(
                active: active || wasActive,
                color: lightColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _SelectedTilePainter extends CustomPainter {
  _SelectedTilePainter({
    this.oldPosition,
    this.newPosition,
    this.progress,
    this.count,
    this.iconSize = 24,
    this.color = Colors.white,
  }) {
    assert(progress != null);
  }

  final int oldPosition, newPosition, count;
  final double iconSize;
  final Color color;
  final double progress;

  Offset startOffset(Size size) {
    var freeSpace = (size.width / count) - iconSize;
    assert(freeSpace >= 0);
    return Offset(
        freeSpace / 2 +
            (freeSpace + iconSize) *
                (oldPosition * (1 - progress) + newPosition * progress),
        1);
  }

  Offset endOffset(Size size) {
    var freeSpace = (size.width / count) - iconSize;
    assert(freeSpace >= 0);
    return Offset(
        freeSpace / 2 +
            (freeSpace + iconSize) *
                (oldPosition * (1 - progress) + newPosition * progress) +
            iconSize,
        1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var p = Paint()
      ..color = this.color
      ..strokeWidth = 2;
    canvas.drawLine(startOffset(size), endOffset(size), p);
  }

  @override
  bool shouldRepaint(_SelectedTilePainter oldDelegate) => true;
}

class _LightLampPainter extends CustomPainter {
  final bool active;
  final double iconSize;
  final Color color;
  final Animation animation;

  _LightLampPainter({
    @required this.active,
    this.animation,
    this.iconSize = 24,
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (active) {
      var p = Paint()
        ..shader = LinearGradient(colors: <Color>[
          color.withAlpha(64),
          color.withAlpha(24),
          color.withAlpha(0)
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)
            .createShader(
          Rect.fromLTWH(0, 0, 56, 56),
        );
      var oldTrap = Path()..addPolygon(getTrap(size), true);
      canvas.drawPath(oldTrap, p);
    }
  }

  @override
  bool shouldRepaint(_LightLampPainter oldDelegate) => true;

  List<Offset> getTrap(Size size, {Offset initial = Offset.zero}) {
    var points = <Offset>[];
    points.add(initial + Offset(14, 0));
    points.add(initial + Offset(-4, 56));
    points.add(initial + Offset(52, 56));
    points.add(initial + Offset(34, 0));
    return points;
  }
}
