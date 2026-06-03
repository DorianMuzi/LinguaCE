import 'package:flutter/widgets.dart';
import 'lingua_scale.dart';

/// Type d'appareil déduit de la largeur disponible.
enum DeviceClass { mobile, tablet, desktop }

/// Helpers responsive (mobile → tablette → desktop).
class Responsive {
  Responsive._();

  static DeviceClass classOf(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= LinguaBreakpoints.desktop) return DeviceClass.desktop;
    if (w >= LinguaBreakpoints.tablet) return DeviceClass.tablet;
    return DeviceClass.mobile;
  }

  static bool isMobile(BuildContext context) =>
      classOf(context) == DeviceClass.mobile;

  static bool isTablet(BuildContext context) =>
      classOf(context) == DeviceClass.tablet;

  static bool isDesktop(BuildContext context) =>
      classOf(context) == DeviceClass.desktop;

  /// Choisit une valeur selon la classe d'appareil.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return switch (classOf(context)) {
      DeviceClass.desktop => desktop ?? tablet ?? mobile,
      DeviceClass.tablet => tablet ?? mobile,
      DeviceClass.mobile => mobile,
    };
  }

  /// Nombre de colonnes recommandé pour une grille.
  static int gridColumns(BuildContext context) =>
      value(context, mobile: 1, tablet: 2, desktop: 3);

  /// Largeur max du contenu centré (évite les lignes trop longues sur desktop).
  static double contentMaxWidth(BuildContext context) =>
      value(context, mobile: double.infinity, tablet: 760, desktop: 960);
}

/// Construit un layout différent selon la classe d'appareil.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, DeviceClass) builder;
  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) =>
      builder(context, Responsive.classOf(context));
}

/// Centre le contenu et borne sa largeur sur grands écrans.
class ContentClamp extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry padding;

  const ContentClamp({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.contentMaxWidth(context),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
