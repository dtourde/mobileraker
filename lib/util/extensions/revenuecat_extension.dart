/*
 * Copyright (c) 2023. Patrick Schmidt.
 * All rights reserved.
 */

import 'package:easy_localization/easy_localization.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

extension MobilerakerDiscount on StoreProductDiscount {
  String get discountDurationText {
    //DAY, WEEK, MONTH or YEAR.
    var dateUnit = switch (periodUnit) {
      'YEAR' => plural('date.year', cycles),
      'MONTH' => plural('date.month', cycles),
      'WEEK' => plural('date.week', cycles),
      'DAY' => plural('date.day', cycles),
      _ => throw ArgumentError('Detected unsupported period')
    };

    return '$cycles $dateUnit';
  }
}

extension MobilerakerIntroductoryPrice on IntroductoryPrice {
  String get discountDurationText {
    String dateUnit = periodUnitToText(periodUnit, cycles);

    return '$cycles $dateUnit';
  }
}

extension MobilerakerOption on SubscriptionOption {
  String? get introPhaseDurationText {
    if (introPhase == null) return null;
    var cycles = introPhase?.billingCycleCount ?? 1;
    var dateUnit = periodUnitToText(introPhase!.billingPeriod?.unit, cycles);

    return '$cycles $dateUnit';
  }

  String? get freePhaseDurationText {
    if (freePhase == null) return null;
    var cycles = freePhase?.billingCycleCount ?? 1;
    var dateUnit = periodUnitToText(freePhase!.billingPeriod?.unit, cycles);

    return '$cycles $dateUnit';
  }
}

String periodUnitToText(PeriodUnit? periodUnit, int cycles) {
  var dateUnit = switch (periodUnit) {
    PeriodUnit.year => plural('date.year', cycles),
    PeriodUnit.month || null => plural('date.month', cycles),
    PeriodUnit.week => plural('date.week', cycles),
    PeriodUnit.day => plural('date.day', cycles),
    _ => throw ArgumentError('Detected unsupported period')
  };
  return dateUnit;
}
