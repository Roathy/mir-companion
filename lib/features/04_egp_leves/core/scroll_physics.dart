import 'package:flutter/material.dart';

class FreeScrollPhysics extends ScrollPhysics {
  const FreeScrollPhysics({super.parent});

  @override
  FreeScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FreeScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // Continue scrolling with the given velocity
    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => true;
}
