import 'package:flutter/widgets.dart';

/// Échelle d'espacement (système 4pt) — façon Copilot, généreux et régulier.
class LinguaSpacing {
  LinguaSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const EdgeInsets pageMobile = EdgeInsets.all(lg);
  static const EdgeInsets pageDesktop = EdgeInsets.all(xxl);
  static const EdgeInsets card = EdgeInsets.all(lg);
}

/// Rayons de coins — arrondis généreux, signature du langage Copilot.
class LinguaRadius {
  LinguaRadius._();
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static const BorderRadius rSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius rPill = BorderRadius.all(Radius.circular(pill));
}

/// Durées d'animation — transitions douces (divulgation progressive).
class LinguaDuration {
  LinguaDuration._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

/// Points de rupture responsive (mobile → desktop).
class LinguaBreakpoints {
  LinguaBreakpoints._();
  static const double mobile = 600;
  static const double tablet = 905;
  static const double desktop = 1240;
}
