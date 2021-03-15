import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cyclopath/util/bottom_drawer.dart';
import 'package:cyclopath/util/map_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const double _kFlingVelocity = 2.0;
const _kAnimationDuration = Duration(milliseconds: 300);

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with TickerProviderStateMixin {
  final _bottomDrawerKey = GlobalKey(debugLabel: 'Bottom Drawer');

  AnimationController _drawerController;
  AnimationController _dropArrowController;

  AnimationController _bottomAppBarController;
  Animation<double> _drawerCurve;
  Animation<double> _dropArrowCurve;
  Animation<double> _bottomAppBarCurve;
  VoidCallback onSelected;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      value: 0,
      duration: _kAnimationDuration,
      vsync: this,
    )..addListener(
        () {
          if (_drawerController.value < 0.01) {
            setState(() {});
          }
        },
      );

    _dropArrowController = AnimationController(
      duration: _kAnimationDuration,
      vsync: this,
    );

    _bottomAppBarController = AnimationController(
      vsync: this,
      value: 1,
      duration: const Duration(milliseconds: 250),
    );

    _drawerCurve = CurvedAnimation(
      parent: _drawerController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );

    _dropArrowCurve = CurvedAnimation(
      parent: _dropArrowController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );

    _bottomAppBarCurve = CurvedAnimation(
      parent: _bottomAppBarController,
      curve: standardEasing,
      reverseCurve: standardEasing.flipped,
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    _dropArrowController.dispose();
    _bottomAppBarController.dispose();
    super.dispose();
  }

  bool get _bottomDrawerVisible {
    final status = _drawerController.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  double get _bottomDrawerHeight {
    final renderBox =
        _bottomDrawerKey.currentContext.findRenderObject() as RenderBox;
    return renderBox.size.height;
  }

  void _toggleBottomDrawerVisibility() {
    if (_drawerController.value < 0.4) {
      _drawerController.animateTo(0.4, curve: standardEasing);
      _dropArrowController.animateTo(0.35, curve: standardEasing);
      return;
    }

    _dropArrowController.forward();
    _drawerController.fling(
        velocity: _bottomDrawerVisible ? -_kFlingVelocity : _kFlingVelocity);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _drawerController.value -= details.primaryDelta / _bottomDrawerHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_drawerController.isAnimating ||
        _drawerController.status == AnimationStatus.completed) {
      return;
    }

    final flingVelocity =
        details.velocity.pixelsPerSecond.dy / _bottomDrawerHeight;

    if (flingVelocity < 0.0) {
      _drawerController.fling(
        velocity: math.max(_kFlingVelocity, -flingVelocity),
      );
    } else if (flingVelocity > 0.0) {
      _dropArrowController.forward();
      _drawerController.fling(
        velocity: math.min(-_kFlingVelocity, -flingVelocity),
      );
    } else {
      if (_drawerController.value < 0.6) {
        _dropArrowController.forward();
      }
      _drawerController.fling(
        velocity:
            _drawerController.value < 0.6 ? -_kFlingVelocity : _kFlingVelocity,
      );
    }
  }

  Widget _bodyStack(context, constraints) {
    final drawerSize = constraints.biggest;
    final drawerTop = drawerSize.height;

    final drawerAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0.0, drawerTop, 0.0, 0.0),
      end: const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_drawerCurve);

    return Stack(
      key: _bottomDrawerKey,
      children: [
        const MapCard(),
        GestureDetector(
          onTap: () {
            _drawerController.reverse();
            _dropArrowController.reverse();
          },
          child: Visibility(
            maintainAnimation: true,
            maintainState: true,
            visible: _bottomDrawerVisible,
            child: FadeTransition(
              opacity: _drawerCurve,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).bottomSheetTheme.modalBackgroundColor,
              ),
            ),
          ),
        ),
        PositionedTransition(
          rect: drawerAnimation,
          child: Visibility(
            visible: _bottomDrawerVisible,
            child: BottomDrawer(
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              // leading: TimeOfDay,
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: _bodyStack),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        // onPressed: _getCurrentLocation,
        child: const Icon(
          Icons.my_location,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _AnimatedBottomAppBar(
        bottomDrawerVisible: _bottomDrawerVisible,
        toggleBottomDrawerVisibility: _toggleBottomDrawerVisibility,
      ),
    );
  }
}

class _AnimatedBottomAppBar extends StatelessWidget {
  const _AnimatedBottomAppBar({
    this.toggleBottomDrawerVisibility,
    this.bottomDrawerVisible,
  });

  final bool bottomDrawerVisible;
  final ui.VoidCallback toggleBottomDrawerVisibility;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 0),
      child: BottomAppBar(
        // elevation: 10.0,
        child: Container(
          height: 80.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                onTap: toggleBottomDrawerVisibility,
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    // RotationTransition(
                    //   turns: Tween(
                    //     begin: 0.0,
                    //     end: 1.0,
                    //   ).animate(),
                    //   child: const
                    const Icon(
                      Icons.arrow_drop_up,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Du bist offline',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
