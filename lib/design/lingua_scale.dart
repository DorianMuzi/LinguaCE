import 'package:flutter/widgets.dart';

/// Échelle d'espacement — grille de 4 px, portée depuis `tokens/spacing.css`.
class LinguaSpacing {
  LinguaSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  /// Gouttière de bord d'écran — `--pad-screen`.
  static const double screen = 20;

  /// Padding interne d'une carte — `--pad-card`.
  static const double card = 18;

  /// Écart entre deux cartes d'une grille — `--gap-card`.
  static const double gapCard = 16;

  /// Écart vertical entre deux sections — `--stack-section`.
  static const double stackSection = 28;

  static const EdgeInsets pageMobile = EdgeInsets.symmetric(horizontal: screen);
  static const EdgeInsets pageDesktop = EdgeInsets.all(xxxl);
  static const EdgeInsets cardPad = EdgeInsets.all(card);
}

/// Rayons de coins — `tokens/effects.css`.
class LinguaRadius {
  LinguaRadius._();
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;

  /// Le rayon d'une carte — la valeur la plus fréquente du système.
  static const double card = 18;
  static const double lg = 22;
  static const double xl = 28;
  static const double pill = 999;

  static const BorderRadius rXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius rSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rCard = BorderRadius.all(Radius.circular(card));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius rPill = BorderRadius.all(Radius.circular(pill));
}

/// Cadre de l'application — `tokens/spacing.css`.
class LinguaFrame {
  LinguaFrame._();

  /// Largeur maximale du canevas mobile. Au-delà, on centre.
  static const double maxWidth = 430;
  static const double tabBarHeight = 64;
  static const double topBarHeight = 60;

  /// Retrait de la barre flottante par rapport aux bords.
  static const double tabBarInset = 14;

  /// Cible tactile minimale. Non négociable, y compris en mode enfant où
  /// elle passe à 64.
  static const double minTarget = 44;
  static const double minTargetKids = 64;
}

/// Le flou du « liquid glass » — `--glass-blur`.
class LinguaGlass {
  LinguaGlass._();
  static const double blur = 22;
  static const double blurStrong = 28;
}

/// Durées d'animation — `tokens/effects.css`.
class LinguaDuration {
  LinguaDuration._();
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
}

/// Courbes — `--ease-out`, `--ease-spring`.
class LinguaCurves {
  LinguaCurves._();
  static const Cubic out = Cubic(0.2, 0.7, 0.3, 1);
  static const Cubic spring = Cubic(0.34, 1.45, 0.6, 1);
}

/// Points de rupture responsive (mobile → desktop).
class LinguaBreakpoints {
  LinguaBreakpoints._();
  static const double mobile = 600;
  static const double tablet = 905;
  static const double desktop = 1240;
}
