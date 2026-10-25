// ignore_for_file: unused_import

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:azmiu_app/core/app_routes.dart';
import 'package:azmiu_app/core/theme/app_colors.dart';
import 'package:azmiu_app/core/theme/app_text_styles.dart';

// ============================================================================
// RƏNG PALİTRASI
// ============================================================================
class _NavColors {
  _NavColors._();

  static const Color primaryBlue = Color(0xFF2E5BFF);
  static const Color purple = Color(0xFF7B68EE);
  static const Color lightBlue = Color(0xFF4A90E2);
  static const Color inactiveGrey = Color(0xFF6B7280);
  static const Color titleDark = Color(0xFF111827);

  static Color get glass => Colors.white.withValues(alpha: 0.18);
}

// ============================================================================
// ÖLÇÜLƏR
// ============================================================================
class _NavSizes {
  _NavSizes._();

  static const double barWidth = 240;
  static const double barHeight = 70;
  static const double bottomGap = 16;
  static const double barRadius = 35;
  static const double centerButton = 56;
  static const double centerBorder = 4;
  static const double labelSize = 10;
  static const double blurSigma = 8;
  static const double sheetRadius = 30;
}

// ============================================================================
// MENYU MƏLUMATI
// ============================================================================
class _MenuEntry {
  const _MenuEntry({
    required this.title,
    required this.icon,
    required this.route,
  });

  final String title;
  final IconData icon;
  final String route;
}

final List<_MenuEntry> _menuEntries = <_MenuEntry>[
  _MenuEntry(
    title: 'Dərs cədvəli',
    icon: Icons.calendar_month_rounded,
    route: AppRoutes.schedule,
  ),
  _MenuEntry(
    title: 'Aylıq nəticələr',
    icon: Icons.description_rounded,
    route: AppRoutes.grades,
  ),
  _MenuEntry(
    title: 'Tədris planı',
    icon: Icons.menu_book_rounded,
    route: AppRoutes.curriculum,
  ),
  _MenuEntry(
    title: 'Elektron jurnal',
    icon: Icons.assignment_rounded,
    route: AppRoutes.journal,
  ),
  _MenuEntry(
    title: 'Elektron materiallar',
    icon: Icons.folder_copy_rounded,
    route: AppRoutes.materials,
  ),
  _MenuEntry(
    title: 'İmtahan sualları',
    icon: Icons.help_center_rounded,
    route: AppRoutes.examQuestions,
  ),
  _MenuEntry(
    title: 'Onlayn dərslər',
    icon: Icons.video_library_rounded,
    route: AppRoutes.onlineLessons,
  ),
  _MenuEntry(
    title: 'İmtahan cədvəli',
    icon: Icons.event_note_rounded,
    route: AppRoutes.examSchedule,
  ),
  _MenuEntry(
    title: 'Yekun bal',
    icon: Icons.analytics_rounded,
    route: AppRoutes.finalGrades,
  ),
  _MenuEntry(
    title: 'Apellyasiya',
    icon: Icons.gavel_rounded,
    route: AppRoutes.appeal,
  ),
  _MenuEntry(
    title: 'LMS',
    icon: Icons.computer_rounded,
    route: AppRoutes.lms,
  ),
  _MenuEntry(
    title: 'Faydalı linklər',
    icon: Icons.link_rounded,
    route: AppRoutes.usefulLinks,
  ),
];

// ============================================================================
// BOTTOM NAV BAR
// ============================================================================

/// AZMİU tələbə tətbiqi üçün üzən (floating), glass effektli alt naviqasiya
/// paneli. Navbarın özündə kölgə / işıq yoxdur, ətrafı tam şəffafdır.
/// LED işıq animasiyası yalnız açılan menyu pəncərəsinin kənarındadır.
///
/// ```dart
/// Scaffold(
///   extendBody: true,
///   bottomNavigationBar: BottomNavBar(
///     currentIndex: _index,
///     onTap: (i) => setState(() => _index = i),
///   ),
/// )
/// ```
/// İndekslər: 0 = Home, 2 = Settings. (1 = Menu düyməsidir, o, sheet açır.)
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  /// Mərkəz düyməsinin açıq/bağlı vəziyyəti (fırlanma + kiçilmə).
  late final AnimationController _buttonController;

  /// Mərkəz düyməsinə toxunma anındakı qısa sıxılma.
  late final AnimationController _pressController;

  /// Navbarın ekrana ilk dəfə yuxarı sürüşərək gəlməsi.
  late final AnimationController _entranceController;

  late final Animation<double> _rotation;
  late final Animation<double> _buttonScale;
  late final Animation<double> _pressScale;
  late final Animation<Offset> _entranceSlide;
  late final Animation<double> _entranceFade;

  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // 45 dərəcə = pi / 4 radian (sağa).
    _rotation = Tween<double>(begin: 0, end: math.pi / 4).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _buttonScale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOutCubic,
      ),
    );

    _pressScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );

    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 1.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _pressController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // HADİSƏLƏR
  // --------------------------------------------------------------------------

  void _handleItemTap(int index) {
    if (index == widget.currentIndex) return;
    HapticFeedback.selectionClick();
    widget.onTap?.call(index);
  }

  Future<void> _handleMenuTap() async {
    if (_menuOpen) return;
    _menuOpen = true;
    HapticFeedback.lightImpact();

    await _pressController.forward();
    await _pressController.reverse();
    if (!mounted) return;

    // Düymə 45° fırlanır və 0.9-a kiçilir.
    _buttonController.forward();

    final _MenuEntry? selected = await showModalBottomSheet<_MenuEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      useSafeArea: true,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 480),
        reverseDuration: Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
      builder: (BuildContext sheetContext) => const _MenuSheet(),
    );

    if (!mounted) return;

    // Pəncərə bağlananda düymə əvvəlki vəziyyətinə qayıdır.
    await _buttonController.reverse();
    _menuOpen = false;

    if (selected != null && mounted) {
      Navigator.of(context).pushNamed(selected.route);
    }
  }

  // --------------------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      heightFactor: 1.0,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: _NavSizes.bottomGap + MediaQuery.of(context).padding.bottom,
        ),
        child: FadeTransition(
          opacity: _entranceFade,
          child: SlideTransition(
            position: _entranceSlide,
            child: SizedBox(
              width: _NavSizes.barWidth,
              height: _NavSizes.barHeight,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(child: _buildGlassBar()),
                  // Menu düyməsi digər ikonlarla eyni səviyyədə (mərkəzdə).
                  _buildCenterButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // GLASS PANEL (kölgəsiz, kənarları şəffaf)
  // --------------------------------------------------------------------------

  Widget _buildGlassBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_NavSizes.barRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: _NavSizes.blurSigma,
          sigmaY: _NavSizes.blurSigma,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _NavColors.glass,
            borderRadius: BorderRadius.circular(_NavSizes.barRadius),
            // Çox nazik qara kənar xətti (navbar seçilsin deyə).
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.35),
              width: 0.5,
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _NavBarItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: widget.currentIndex == 0,
                  onTap: () => _handleItemTap(0),
                ),
              ),
              const SizedBox(width: _NavSizes.centerButton + 4),
              Expanded(
                child: _NavBarItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  selected: widget.currentIndex == 2,
                  onTap: () => _handleItemTap(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // MƏRKƏZ DÜYMƏSİ
  // --------------------------------------------------------------------------

  Widget _buildCenterButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _pressController.forward(),
      onTapCancel: () => _pressController.reverse(),
      onTapUp: (_) => _pressController.reverse(),
      onTap: _handleMenuTap,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          _buttonController,
          _pressController,
        ]),
        builder: (BuildContext context, Widget? child) {
          final double open = _buttonController.value;

          return Transform.scale(
            scale: _buttonScale.value * _pressScale.value,
            child: Transform.rotate(
              angle: _rotation.value,
              child: Container(
                width: _NavSizes.centerButton,
                height: _NavSizes.centerButton,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      _NavColors.lightBlue,
                      _NavColors.purple,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: _NavSizes.centerBorder,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: _NavColors.primaryBlue.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // Grid ikonu yavaş-yavaş yox olur...
                    Opacity(
                      opacity: (1 - open * 1.6).clamp(0.0, 1.0),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    // ...və düymə fırlandıqca düz duran X işarəsi görünür.
                    Opacity(
                      opacity: ((open - 0.4) * 1.7).clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: -math.pi / 4,
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// NAV ELEMENTİ (Home / Settings)
// ============================================================================
class _NavBarItem extends StatefulWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      value: widget.selected ? 1.0 : 0.0,
    );

    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _bounce = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 55,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant _NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      if (widget.selected) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final Color color = Color.lerp(
            _NavColors.inactiveGrey,
            _NavColors.primaryBlue,
            _curve.value,
          )!;
          final double scale = widget.selected ? _bounce.value : 1.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Transform.scale(
                scale: scale,
                child: Icon(widget.icon, color: color, size: 26),
              ),
              const SizedBox(height: 3),
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: _NavSizes.labelSize,
                  fontWeight:
                      widget.selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              // Aktiv göstərici nöqtə.
              Container(
                width: 4 * _curve.value,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// AÇILAN MENYU (glass + animasiyalı LED kənar)
// ============================================================================
class _MenuSheet extends StatefulWidget {
  const _MenuSheet();

  @override
  State<_MenuSheet> createState() => _MenuSheetState();
}

class _MenuSheetState extends State<_MenuSheet> with TickerProviderStateMixin {
  /// Keçidlərin ardıcıl yuxarı sürüşməsi + LED xəttinin "çəkilməsi".
  late final AnimationController _itemsController;

  /// LED kometlərinin kənar boyunca hərəkəti.
  late final AnimationController _travelController;

  /// LED xəttinin yavaş "nəfəs alması".
  late final AnimationController _breatheController;

  late final Animation<double> _reveal;
  late final Animation<double> _breathe;
  late final List<Animation<Offset>> _slides;
  late final List<Animation<double>> _fades;

  @override
  void initState() {
    super.initState();

    _itemsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _travelController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _reveal = CurvedAnimation(
      parent: _itemsController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    );

    _breathe = CurvedAnimation(
      parent: _breatheController,
      curve: Curves.easeInOutSine,
    );

    _slides = <Animation<Offset>>[];
    _fades = <Animation<double>>[];

    for (int i = 0; i < _menuEntries.length; i++) {
      // Hər keçid öz növbəsində aşağıdan yuxarıya sürüşür (stagger).
      final double start = (0.05 * i).clamp(0.0, 0.6);
      final double end = (start + 0.4).clamp(0.0, 1.0);
      final CurvedAnimation curved = CurvedAnimation(
        parent: _itemsController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );

      _slides.add(
        Tween<Offset>(
          begin: const Offset(0, 0.8),
          end: Offset.zero,
        ).animate(curved),
      );
      _fades.add(curved);
    }

    // Pəncərənin öz açılış animasiyası ilə üst-üstə düşməsin deyə qısa gecikmə.
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _itemsController.forward();
    });
  }

  @override
  void dispose() {
    _itemsController.dispose();
    _travelController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    const BorderRadius topRadius = BorderRadius.vertical(
      top: Radius.circular(_NavSizes.sheetRadius),
    );

    return CustomPaint(
      foregroundPainter: _SheetLedPainter(
        travel: _travelController,
        breathe: _breathe,
        reveal: _reveal,
        radius: _NavSizes.sheetRadius,
      ),
      child: ClipRRect(
        borderRadius: topRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: topRadius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.white.withValues(alpha: 0.52),
                  Colors.white.withValues(alpha: 0.34),
                ],
              ),
            ),
            padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Tutacaq xətti.
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _NavColors.titleDark.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Menyu',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _NavColors.titleDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: _menuEntries.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.92,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return SlideTransition(
                      position: _slides[index],
                      child: FadeTransition(
                        opacity: _fades[index],
                        child: _MenuTile(
                          entry: _menuEntries[index],
                          onTap: () =>
                              Navigator.of(context).pop(_menuEntries[index]),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LED KƏNAR XƏTTİ (menyu pəncərəsi üçün)
//
// Bulanıq parıltı YOXDUR: yalnız çox nazik, kəskin xətlər:
//   1) Mərkəzdən yanlara "çəkilən" nazik baza xətti (gradient, nəfəs alır).
//   2) Kənar boyunca əks istiqamətlərdə hərəkət edən, quyruğu sönən kometlər.
//   3) Kənarda yanıb-sönən kiçik qığılcım nöqtələri.
// ============================================================================
class _SheetLedPainter extends CustomPainter {
  _SheetLedPainter({
    required this.travel,
    required this.breathe,
    required this.reveal,
    required this.radius,
  }) : super(repaint: Listenable.merge(<Listenable>[travel, breathe, reveal]));

  final Animation<double> travel;
  final Animation<double> breathe;
  final Animation<double> reveal;
  final double radius;

  /// Yalnız yuxarı künclər yumru olan açıq yol:
  /// sol-alt → yuxarı → yuxarı-sol künc → yuxarı xətt → yuxarı-sağ künc → sağ-alt.
  Path _buildPath(Size size) {
    const double inset = 0.8;
    final double w = size.width - inset;
    final double h = size.height;
    final Radius r = Radius.circular(radius);

    return Path()
      ..moveTo(inset, h)
      ..lineTo(inset, radius)
      ..arcToPoint(Offset(radius, inset), radius: r)
      ..lineTo(w - radius, inset)
      ..arcToPoint(Offset(w, radius), radius: r)
      ..lineTo(w, h);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final PathMetric metric = _buildPath(size).computeMetrics().first;
    final double total = metric.length;
    final double t = travel.value;
    final double b = breathe.value;
    final double rv = reveal.value.clamp(0.0, 1.0);

    // ---- 1) Baza xətti: mərkəzdən iki tərəfə doğru açılır -------------------
    final double mid = total / 2;
    final Path base = metric.extractPath(mid * (1 - rv), mid * (1 + rv));
    final Paint basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          _NavColors.lightBlue.withValues(alpha: 0.35 + 0.30 * b),
          _NavColors.purple.withValues(alpha: 0.35 + 0.30 * (1 - b)),
          _NavColors.lightBlue.withValues(alpha: 0.35 + 0.30 * b),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(base, basePaint);

    // Açılış bitməyibsə kometlər hələ görünməsin.
    if (rv < 0.85) return;
    final double live = ((rv - 0.85) / 0.15).clamp(0.0, 1.0);

    // Rəng zamanla mavi ↔ bənövşəyi arasında axır.
    final Color flowA = Color.lerp(_NavColors.lightBlue, _NavColors.purple, b)!;
    final Color flowB = Color.lerp(_NavColors.purple, _NavColors.lightBlue, b)!;

    // ---- 2) Kometlər ---------------------------------------------------------
    _drawComet(
      canvas,
      metric,
      total,
      p: (t) % 1.0,
      forward: true,
      lengthFraction: 0.24,
      head: Colors.white,
      tail: flowA,
      width: 1.7,
      opacity: live,
    );
    _drawComet(
      canvas,
      metric,
      total,
      p: (t + 0.5) % 1.0,
      forward: false,
      lengthFraction: 0.24,
      head: Colors.white,
      tail: flowB,
      width: 1.7,
      opacity: live,
    );
    _drawComet(
      canvas,
      metric,
      total,
      p: (t * 2 + 0.3) % 1.0,
      forward: true,
      lengthFraction: 0.09,
      head: Colors.white,
      tail: _NavColors.primaryBlue,
      width: 1.3,
      opacity: live * 0.9,
    );

    // ---- 3) Qığılcımlar ------------------------------------------------------
    const List<double> spots = <double>[0.12, 0.34, 0.66, 0.88];
    for (int i = 0; i < spots.length; i++) {
      final double twinkle =
          0.5 + 0.5 * math.sin(2 * math.pi * (t * 3 + i * 0.27));
      final Tangent? tg = metric.getTangentForOffset(total * spots[i]);
      if (tg == null) continue;
      canvas.drawCircle(
        tg.position,
        0.9 + 0.7 * twinkle,
        Paint()..color = Colors.white.withValues(alpha: 0.85 * twinkle * live),
      );
    }
  }

  void _drawComet(
    Canvas canvas,
    PathMetric metric,
    double total, {
    required double p,
    required bool forward,
    required double lengthFraction,
    required Color head,
    required Color tail,
    required double width,
    required double opacity,
  }) {
    // Yolun əvvəlində / sonunda yumşaq görünüb-itmə.
    final double edgeFade = math.min(1.0, math.min(p, 1 - p) / 0.06);
    final double fade = edgeFade * opacity;
    if (fade <= 0.01) return;

    final double headPos = forward ? p * total : (1 - p) * total;
    const int segments = 28;
    final double segLen = total * lengthFraction / segments;

    for (int k = 0; k < segments; k++) {
      double a = forward ? headPos - (k + 1) * segLen : headPos + k * segLen;
      double bb = forward ? headPos - k * segLen : headPos + (k + 1) * segLen;
      a = a.clamp(0.0, total);
      bb = bb.clamp(0.0, total);
      if (bb - a < 0.01) continue;

      final double f = 1 - k / segments; // 1 = baş, 0 = quyruq ucu
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = width * (0.35 + 0.65 * f)
        ..color = Color.lerp(tail, head, f * f)!
            .withValues(alpha: (f * f * fade).clamp(0.0, 1.0));
      canvas.drawPath(metric.extractPath(a, bb), paint);
    }

    final Tangent? tg =
        metric.getTangentForOffset(headPos.clamp(0.0, total));
    if (tg != null) {
      canvas.drawCircle(
        tg.position,
        width * 0.85,
        Paint()..color = head.withValues(alpha: fade),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SheetLedPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.travel != travel ||
        oldDelegate.breathe != breathe ||
        oldDelegate.reveal != reveal;
  }
}

// ============================================================================
// MENYU KEÇİDİ (tək kart, glass üslubunda)
// ============================================================================
class _MenuTile extends StatefulWidget {
  const _MenuTile({required this.entry, required this.onTap});

  final _MenuEntry entry;
  final VoidCallback onTap;

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _pressController.forward(),
      onTapCancel: () => _pressController.reverse(),
      onTapUp: (_) => _pressController.reverse(),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      _NavColors.lightBlue.withValues(alpha: 0.22),
                      _NavColors.purple.withValues(alpha: 0.22),
                    ],
                  ),
                ),
                child: Icon(
                  widget.entry.icon,
                  color: _NavColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.entry.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _NavColors.titleDark,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}