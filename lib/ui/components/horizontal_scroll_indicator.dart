/*
 * Copyright (c) 2023-2024. Patrick Schmidt.
 * All rights reserved.
 */

import 'dart:math';

import 'package:common/util/logger.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class HorizontalScrollIndicator extends StatefulWidget {
  final int steps;
  final ScrollController controller;
  final int? childsPerScreen;

  const HorizontalScrollIndicator({
    Key? key,
    required this.steps,
    required this.controller,
    this.childsPerScreen,
  })  : assert(steps > 0),
        super(key: key);

  @override
  State<HorizontalScrollIndicator> createState() => _HorizontalScrollIndicatorState();
}

class _HorizontalScrollIndicatorState extends State<HorizontalScrollIndicator> {
  late final int steps;

  double _curIndex = 0;

  ScrollController get controller => widget.controller;

  PageController get pageController => widget.controller as PageController;

  @override
  initState() {
    super.initState();
    steps = (widget.childsPerScreen == null) ? widget.steps : (widget.steps / widget.childsPerScreen!).ceil();

    if (controller is PageController?) {
      logger.d(
        'initiPage ${pageController.initialPage} - ${pageController.hasClients}',
      );
      controller.addListener(_updateIndexFromPage);
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndexFromPage());
    } else {
      controller.addListener(_updateIndexFromOffset);
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndexFromOffset());
    }
  }

  _updateIndexFromOffset() {
    if (!controller.hasClients || !controller.position.hasContentDimensions) {
      return;
    }
    double maxScrollExtent = controller.position.maxScrollExtent;
    if (maxScrollExtent == 0) return;

    double offset = controller.offset;
    double newIndex = min(steps - 1, max(0, steps * offset / maxScrollExtent - 1));
    if ((_curIndex - newIndex).abs() < 0.2) return;
    setState(() {
      _curIndex = newIndex;
    });
  }

  _updateIndexFromPage() {
    if (!pageController.hasClients) {
      return;
    }

    var newIndex = pageController.page ?? 0;
    if ((_curIndex - newIndex).abs() < 0.2) return;
    setState(() {
      _curIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: steps,
      position: max(_curIndex, 0),
      decorator: DotsDecorator(activeColor: Theme.of(context).colorScheme.primary),
    );
  }

  @override
  dispose() {
    widget.controller.removeListener(_updateIndexFromOffset);
    widget.controller.removeListener(_updateIndexFromPage);
    super.dispose();
  }
}
