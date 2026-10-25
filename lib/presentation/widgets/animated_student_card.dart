import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// ============================================================================
// ANİMASİYALI TƏLƏBƏ KARTI
//
// Ssenari (dövr):
//   1) Kartın kənarında nazik LED xətti dövr edir (iki komet + dolan xətt).
//   2) Xətt başlanğıc nöqtəsinə çatanda kart "yüklənir" (titrəyir, parlayır).
//   3) Kart parçalanır (real şəkil parçaları + qığılcımlar + şok dalğası).
//   4) Yeni dizayn (yeni rəng və naxış) dairəvi açılma və xəttin "çəkilməsi"
//      ilə yenidən yaranır. Dövr təkrarlanır.
//
// Funksiyalar dəyişməyib:
//   - kart toxunuşu  -> onTap
//   - QR düyməsi     -> onQrTap (verilməyibsə onTap)
//   - uzun basma     -> partlayışı dərhal başladır
// ============================================================================

// ----------------------------------------------------------------------------
// FAZALAR
// ----------------------------------------------------------------------------
enum _CardPhase { idle, capturing, bursting, assembling }

// ----------------------------------------------------------------------------
// DİZAYN TEMALARI
// ----------------------------------------------------------------------------
enum _PatternKind { circles, waves, dots, stripes }

class _CardTheme {
  const _CardTheme({
    required this.name,
    required this.colors,
    required this.accent,
    required this.accent2,
    required this.pattern,
    required this.shadow,
  });

  final String name;
  final List<Color> colors;
  final Color accent;
  final Color accent2;
  final _PatternKind pattern;
  final Color shadow;
}

const List<_CardTheme> _themes = <_CardTheme>[
  _CardTheme(
    name: 'Okean',
    colors: <Color>[Color(0xFF1C3557), Color(0xFF2E5BFF), Color(0xFF4A90E2)],
    accent: Color(0xFF8FE3FF),
    accent2: Color(0xFF7B68EE),
    pattern: _PatternKind.circles,
    shadow: Color(0xFF2E5BFF),
  ),
  _CardTheme(
    name: 'Aurora',
    colors: <Color>[Color(0xFF22164F), Color(0xFF7B68EE), Color(0xFFC86DD7)],
    accent: Color(0xFFFFD1FF),
    accent2: Color(0xFF5EEAD4),
    pattern: _PatternKind.waves,
    shadow: Color(0xFF7B68EE),
  ),
  _CardTheme(
    name: 'Zümrüd',
    colors: <Color>[Color(0xFF0B3B33), Color(0xFF0F766E), Color(0xFF34D399)],
    accent: Color(0xFFB6FFE4),
    accent2: Color(0xFF4A90E2),
    pattern: _PatternKind.dots,
    shadow: Color(0xFF0F766E),
  ),
  _CardTheme(
    name: 'Qürub',
    colors: <Color>[Color(0xFF2A1B4D), Color(0xFFB5338A), Color(0xFFFF8A5B)],
    accent: Color(0xFFFFE0B2),
    accent2: Color(0xFF7B68EE),
    pattern: _PatternKind.stripes,
    shadow: Color(0xFFB5338A),
  ),
];

// ----------------------------------------------------------------------------
// TƏLƏBƏ MƏLUMATI (model sahələrini təhlükəsiz oxuyur)
// ----------------------------------------------------------------------------
class _StudentView {
  const _StudentView({
    required this.name,
    required this.major,
    required this.group,
    required this.number,
    required this.year,
    required this.level,
  });

  final String name;
  final String major;
  final String group;
  final String number;
  final String year;
  final String level;

  String get initial {
    final String t = name.trim();
    if (t.isEmpty) return '?';
    return t.substring(0, 1).toUpperCase();
  }

  static String? _read(dynamic Function() getter) {
    try {
      final dynamic value = getter();
      if (value == null) return null;
      final String text = value.toString().trim();
      if (text.isEmpty || text == 'null') return null;
      return text;
    } catch (_) {
      // Model-də belə sahə yoxdursa növbəti variantı yoxla.
      return null;
    }
  }

  static String _first(List<dynamic Function()> getters, String fallback) {
    for (final dynamic Function() getter in getters) {
      final String? value = _read(getter);
      if (value != null) return value;
    }
    return fallback;
  }

  factory _StudentView.fromModel(
    dynamic s, {
    String? name,
    String? major,
    String? group,
    String? number,
    String? year,
    String? level,
  }) {
    return _StudentView(
      name: name ??
          _first(
            <dynamic Function()>[() => s.displayName, () => s.fullName],
            'Tələbə',
          ),
      major: major ??
          _first(
            <dynamic Function()>[
              () => s.speciality,
              () => s.specialty,
              () => s.major,
              () => s.profession,
              () => s.direction,
            ],
            '---',
          ),
      group: group ??
          _first(
            <dynamic Function()>[
              () => s.group,
              () => s.groupName,
              () => s.groupCode,
            ],
            '---',
          ),
      number: number ??
          _first(
            <dynamic Function()>[
              () => s.studentNumber,
              () => s.studentId,
              () => s.number,
              () => s.cardNumber,
              () => s.id,
            ],
            '---',
          ),
      year: year ??
          _first(
            <dynamic Function()>[
              () => s.academicYear,
              () => s.studyYear,
              () => s.year,
            ],
            '---',
          ),
      level: level ??
          _first(
            <dynamic Function()>[
              () => s.educationLevel,
              () => s.level,
              () => s.degree,
              () => s.studyLevel,
            ],
            '---',
          ),
    );
  }
}

// ============================================================================
// ƏSAS WIDGET
// ============================================================================
class AnimatedStudentCard extends StatefulWidget {
  const AnimatedStudentCard({
    super.key,
    this.student,
    this.onTap,
    this.onQrTap,
    this.photo,
    this.name,
    this.major,
    this.group,
    this.studentNumber,
    this.academicYear,
    this.level,
    this.height = 244,
  });

  /// StudentModel (hər hansı obyekt). Sahələr avtomatik oxunur.
  final dynamic student;

  final VoidCallback? onTap;
  final VoidCallback? onQrTap;
  final ImageProvider? photo;

  /// İstəyə görə modeldəki dəyərləri əvəz etmək üçün.
  final String? name;
  final String? major;
  final String? group;
  final String? studentNumber;
  final String? academicYear;
  final String? level;

  final double height;

  @override
  State<AnimatedStudentCard> createState() => _AnimatedStudentCardState();
}

class _AnimatedStudentCardState extends State<AnimatedStudentCard>
    with TickerProviderStateMixin {
  static const double _radius = 26;

  final GlobalKey _boundaryKey = GlobalKey();
  final ValueNotifier<Offset> _tilt = ValueNotifier<Offset>(Offset.zero);

  /// Kənar xəttinin bir dövrü (başlanğıc nöqtəsinə qayıdanda partlayış).
  AnimationController? _orbit;

  /// Yavaş "nəfəs" və üzmə.
  AnimationController? _pulse;

  /// Parçalanma + qığılcımlar.
  AnimationController? _burst;

  /// Yeni kartın yaranması.
  AnimationController? _assemble;

  /// Əyilmənin yumşaq geri qayıtması.
  AnimationController? _tiltBack;

  Offset _tiltFrom = Offset.zero;

  _CardPhase _phase = _CardPhase.idle;
  int _themeIndex = 0;

  ui.Image? _image;
  List<_Shard> _shards = const <_Shard>[];
  List<_Spark> _sparks = const <_Spark>[];

  @override
  void initState() {
    super.initState();

    final AnimationController orbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
    orbit.addStatusListener(_onOrbitStatus);

    final AnimationController tiltBack = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    tiltBack.addListener(() {
      final double t = Curves.easeOutBack.transform(tiltBack.value);
      _tilt.value = Offset.lerp(_tiltFrom, Offset.zero, t) ?? Offset.zero;
    });

    _orbit = orbit;
    _tiltBack = tiltBack;
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
    _assemble = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    orbit.forward();
  }

  @override
  void dispose() {
    _orbit?.dispose();
    _pulse?.dispose();
    _burst?.dispose();
    _assemble?.dispose();
    _tiltBack?.dispose();
    _tilt.dispose();
    _image?.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // DÖVR MƏNTİQİ
  // --------------------------------------------------------------------------

  void _onOrbitStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _phase == _CardPhase.idle) {
      _startBurst();
    }
  }

   Future<void> _startBurst() async {
    final AnimationController? burst = _burst;
    final AnimationController? assemble = _assemble;
    final AnimationController? orbit = _orbit;
    if (burst == null || assemble == null || orbit == null) return;
    if (_phase != _CardPhase.idle) return;

    setState(() => _phase = _CardPhase.capturing);

    // 1. Şəkil çəkməyə cəhd et, amma uğursuz olsa da davam et
    Size size = Size.zero;
    ui.Image? captured;
    
    try {
      final RenderObject? object = _boundaryKey.currentContext?.findRenderObject();
      if (object is RenderRepaintBoundary) {
        size = object.size;
        // Yalnız debug rejimində toImage() işləyir, release-də null qaytarır
        // Ona görə də try-catch ilə əhatə edirik
        try {
          captured = await object.toImage(pixelRatio: 1.5);
        } catch (_) {
          captured = null;
        }
      }
    } catch (_) {
      captured = null;
    }

    if (!mounted) {
      captured?.dispose();
      return;
    }

    if (size.isEmpty) {
      size = context.size ?? Size(300, widget.height);
    }

    // 2. Parçaları və qığılcımları hazırla
    final math.Random random = math.Random();
    _shards = _Shard.generate(size, random);
    _sparks = _Spark.generate(random);
    _image?.dispose();
    _image = captured; // Əgər null-dursa, rənglərlə partlayacaq

    setState(() => _phase = _CardPhase.bursting);
    HapticFeedback.heavyImpact();
    await burst.forward(from: 0);
    if (!mounted) return;

    // 3. Yeni dizayn ilə kartı yenidən yarat
    _image?.dispose();
    _image = null;
    _shards = const <_Shard>[];
    _sparks = const <_Spark>[];

    setState(() {
      _themeIndex = (_themeIndex + 1) % _themes.length;
      _phase = _CardPhase.assembling;
    });
    HapticFeedback.selectionClick();
    await assemble.forward(from: 0);
    if (!mounted) return;

    setState(() => _phase = _CardPhase.idle);
    orbit.forward(from: 0);
  }
  // --------------------------------------------------------------------------
  // HADİSƏLƏR
  // --------------------------------------------------------------------------

  void _handleTap() {
    if (_phase == _CardPhase.bursting || _phase == _CardPhase.capturing) return;
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (_phase != _CardPhase.idle) return;
    HapticFeedback.mediumImpact();
    _startBurst();
  }

  void _handleQr() {
    HapticFeedback.selectionClick();
    final VoidCallback? qr = widget.onQrTap ?? widget.onTap;
    qr?.call();
  }

  void _onPointer(PointerEvent event) {
    final Size? size = _boundaryKey.currentContext?.size;
    if (size == null || size.isEmpty) return;

    _tiltBack?.stop();
    final double dx = ((event.localPosition.dx / size.width) - 0.5) * 2;
    final double dy = ((event.localPosition.dy / size.height) - 0.5) * 2;
    _tilt.value = Offset(dx.clamp(-1.0, 1.0) * 0.16, dy.clamp(-1.0, 1.0) * 0.16);
  }

  void _resetTilt(PointerEvent event) {
    _tiltFrom = _tilt.value;
    _tiltBack?.forward(from: 0);
  }

  // --------------------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final AnimationController? orbit = _orbit;
    final AnimationController? pulse = _pulse;
    final AnimationController? burst = _burst;
    final AnimationController? assemble = _assemble;

    if (orbit == null || pulse == null || burst == null || assemble == null) {
      return SizedBox(height: widget.height + 40);
    }

    final _CardTheme theme = _themes[_themeIndex];
    final _StudentView data = _StudentView.fromModel(
      widget.student,
      name: widget.name,
      major: widget.major,
      group: widget.group,
      number: widget.studentNumber,
      year: widget.academicYear,
      level: widget.level,
    );

    return SizedBox(
      height: widget.height + 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // Canlı kart (partlayış zamanı gizlədilir, amma yerini saxlayır).
            Positioned.fill(
              child: Visibility(
                visible: _phase != _CardPhase.bursting,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: true,
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: _onPointer,
                  onPointerMove: _onPointer,
                  onPointerUp: _resetTilt,
                  onPointerCancel: _resetTilt,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _handleTap,
                    onLongPress: _handleLongPress,
                    child: _buildLiveLayer(theme, data, orbit, pulse, assemble),
                  ),
                ),
              ),
            ),
            // Partlayış qatı: parçalar, qığılcımlar, şok dalğası.
            if (_phase == _CardPhase.bursting)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _BurstPainter(
                      progress: burst,
                      shards: _shards,
                      sparks: _sparks,
                      image: _image,
                      theme: theme,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveLayer(
    _CardTheme theme,
    _StudentView data,
    AnimationController orbit,
    AnimationController pulse,
    AnimationController assemble,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[orbit, pulse, assemble, _tilt]),
      builder: (BuildContext context, Widget? child) {
        final bool assembling = _phase == _CardPhase.assembling;
        final double a = assembling ? assemble.value : 1.0;
        final double p = orbit.value;
        final double pu = pulse.value;

        // Partlayışdan əvvəl kart titrəyir.
        double shakeX = 0;
        double shakeY = 0;
        if (_phase == _CardPhase.idle && p > 0.9) {
          final double amp = ((p - 0.9) / 0.1) * 2.4;
          shakeX = math.sin(p * 900) * amp;
          shakeY = math.cos(p * 1300) * amp * 0.6;
        }

        // Yüngül üzmə.
        final double bob = (pu - 0.5) * 4;

        final Offset tilt = _tilt.value;
        final Matrix4 matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0011)
          ..rotateX(-tilt.dy)
          ..rotateY(tilt.dx);

        final double scale =
            assembling ? 0.88 + 0.12 * Curves.easeOutBack.transform(a) : 1.0;
        final double reveal = a;
        final double fraction = Curves.easeOutCubic.transform(a);

        final double shadowAlpha = 0.30 +
            0.12 * pu +
            (assembling ? 0.25 * (1 - a) : 0.0) +
            (_phase == _CardPhase.idle && p > 0.88
                ? 0.3 * ((p - 0.88) / 0.12)
                : 0.0);

        final Widget card = DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: theme.shadow.withValues(alpha: shadowAlpha.clamp(0.0, 0.8)),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipPath(
            clipper: _CircleRevealClipper(assembling ? fraction : 1.0),
            clipBehavior: assembling ? Clip.antiAlias : Clip.none,
            child: RepaintBoundary(
              key: _boundaryKey,
              child: Stack(
                children: <Widget>[
                  _CardFace(
                    theme: theme,
                    data: data,
                    reveal: reveal,
                    orbit: orbit,
                    radius: _radius,
                    photo: widget.photo,
                    onQrTap: _handleQr,
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: assembling
                            ? _BuildRingPainter(
                                progress: a,
                                theme: theme,
                                radius: _radius,
                              )
                            : _OrbitBorderPainter(
                                orbit: orbit,
                                pulse: pulse,
                                theme: theme,
                                radius: _radius,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        return Transform.translate(
          offset: Offset(shakeX, bob + shakeY),
          child: Transform(
            alignment: Alignment.center,
            transform: matrix,
            child: Transform.scale(scale: scale, child: card),
          ),
        );
      },
    );
  }
}

// ============================================================================
// KARTIN ÖN YÜZÜ (fon, naxış, parıltı, məzmun)
// ============================================================================
class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.theme,
    required this.data,
    required this.reveal,
    required this.orbit,
    required this.radius,
    required this.onQrTap,
    this.photo,
  });

  final _CardTheme theme;
  final _StudentView data;
  final double reveal;
  final Animation<double> orbit;
  final double radius;
  final VoidCallback onQrTap;
  final ImageProvider? photo;

  /// 0..1 aralığında [start, end] pəncərəsində görünmə + yuxarı sürüşmə.
  Widget _staggered(double start, double end, Widget child) {
    final double v = Interval(start, end, curve: Curves.easeOutCubic)
        .transform(reveal.clamp(0.0, 1.0));
    return Opacity(
      opacity: v,
      child: Transform.translate(
        offset: Offset(0, 16 * (1 - v)),
        child: child,
      ),
    );
  }

  Widget _glowCircle(double size, Color color, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.colors,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: <Widget>[
            // Naxış (hər temada fərqli).
            Positioned.fill(
              child: CustomPaint(
                painter: _PatternPainter(
                  kind: theme.pattern,
                  line: Colors.white.withValues(alpha: 0.10),
                  accent: theme.accent.withValues(alpha: 0.22),
                ),
              ),
            ),
            // Şüşə parıltısı.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0.20),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                    stops: const <double>[0.0, 0.6],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -30,
              child: _glowCircle(190, theme.accent, 0.22),
            ),
            Positioned(
              bottom: -70,
              left: -40,
              child: _glowCircle(210, theme.accent2, 0.20),
            ),
            // Gəzən işıq zolağı.
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ShinePainter(orbit: orbit)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _staggered(0.00, 0.40, _buildTopRow()),
        const SizedBox(height: 14),
        _staggered(0.12, 0.55, _buildIdentity()),
        const Spacer(),
        _staggered(0.30, 0.75, _buildChips()),
        const SizedBox(height: 10),
        _staggered(0.45, 0.90, _buildFooter()),
      ],
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.38),
              width: 0.8,
            ),
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'AZMİU',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            Text(
              'Tələbə vəsiqəsi',
              style: TextStyle(color: Colors.white70, fontSize: 10.5),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onQrTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentity() {
    return Row(
      children: <Widget>[
        _buildAvatar(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                data.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.school_outlined,
                    size: 15,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      data.major,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final ImageProvider? image = photo;

    return Container(
      width: 62,
      height: 62,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[theme.accent, theme.accent2],
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colors.first.withValues(alpha: 0.85),
          image: image == null
              ? null
              : DecorationImage(image: image, fit: BoxFit.cover),
        ),
        child: image == null
            ? Text(
                data.initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildChips() {
    return Row(
      children: <Widget>[
        Expanded(child: _InfoChip(label: 'Tələbə №', value: data.number)),
        const SizedBox(width: 8),
        Expanded(child: _InfoChip(label: 'Qrup', value: data.group)),
        const SizedBox(width: 8),
        Expanded(child: _InfoChip(label: 'Səviyyə', value: data.level)),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: <Widget>[
        Icon(
          Icons.calendar_month_rounded,
          size: 16,
          color: Colors.white.withValues(alpha: 0.85),
        ),
        const SizedBox(width: 6),
        Text(
          'Tədris ili  ${data.year}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        const Icon(Icons.account_balance_rounded, size: 16, color: Colors.white),
        const SizedBox(width: 5),
        const Text(
          'AZMİU',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.24),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DAİRƏVİ AÇILMA (yeni kart yaranarkən)
// ============================================================================
class _CircleRevealClipper extends CustomClipper<Path> {
  _CircleRevealClipper(this.fraction);

  final double fraction;

  @override
  Path getClip(Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = math.sqrt(
      size.width * size.width / 4 + size.height * size.height / 4,
    );
    return Path()
      ..addOval(
        Rect.fromCircle(center: center, radius: maxRadius * fraction + 0.01),
      );
  }

  @override
  bool shouldReclip(covariant _CircleRevealClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}

// ============================================================================
// KƏNAR YOLU (başlanğıc: yuxarı mərkəz, saat əqrəbi istiqamətində)
// ============================================================================
Path _borderPath(Size size, double radius) {
  const double inset = 0.75;
  final double w = size.width - inset;
  final double h = size.height - inset;
  final Radius r = Radius.circular(radius);

  return Path()
    ..moveTo(size.width / 2, inset)
    ..lineTo(w - radius, inset)
    ..arcToPoint(Offset(w, inset + radius), radius: r)
    ..lineTo(w, h - radius)
    ..arcToPoint(Offset(w - radius, h), radius: r)
    ..lineTo(inset + radius, h)
    ..arcToPoint(Offset(inset, h - radius), radius: r)
    ..lineTo(inset, inset + radius)
    ..arcToPoint(Offset(inset + radius, inset), radius: r)
    ..lineTo(size.width / 2, inset);
}

/// [a, b] aralığını çıxarır. a mənfi ola bilər (yolun sonundan davam edir).
Path _segment(ui.PathMetric metric, double total, double a, double b) {
  if (b <= 0) return metric.extractPath(a + total, b + total);
  if (a >= 0) return metric.extractPath(a, b);

  final Path path = metric.extractPath(total + a, total);
  path.addPath(metric.extractPath(0, b), Offset.zero);
  return path;
}

// ============================================================================
// KƏNAR LED XƏTTİ (dövr edən kometlər, dolan xətt, başlanğıc nöqtəsi)
// ============================================================================
class _OrbitBorderPainter extends CustomPainter {
  _OrbitBorderPainter({
    required this.orbit,
    required this.pulse,
    required this.theme,
    required this.radius,
  }) : super(repaint: Listenable.merge(<Listenable>[orbit, pulse]));

  final Animation<double> orbit;
  final Animation<double> pulse;
  final _CardTheme theme;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final Path path = _borderPath(size, radius);
    final ui.PathMetric metric = path.computeMetrics().first;
    final double total = metric.length;

    final double p = orbit.value.clamp(0.0, 1.0);
    final double pu = pulse.value;
    final double energy = ((p - 0.88) / 0.12).clamp(0.0, 1.0);

    // 1) Baza xətti (çox nazik).
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = Colors.white.withValues(alpha: 0.22 + 0.10 * pu),
    );

    // 2) Artıq keçilmiş hissə (xətt dolur).
    if (p > 0.002) {
      canvas.drawPath(
        metric.extractPath(0, total * p),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.1 + 0.7 * energy
          ..shader = LinearGradient(
            colors: <Color>[
              theme.accent2.withValues(alpha: 0.25),
              theme.accent.withValues(alpha: 0.95),
            ],
          ).createShader(Offset.zero & size),
      );
    }

    // 3) Partlayışa az qalmış bütün xətt "həddindən artıq yüklənir".
    if (energy > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0 + 1.5 * energy
          ..color = Color.lerp(theme.accent, Colors.white, energy)!
              .withValues(alpha: 0.25 + 0.65 * energy),
      );
    }

    // 4) İki komet (əks nöqtələrdə).
    final double head = total * p;
    _drawComet(
      canvas,
      metric,
      total,
      head: head,
      tailFraction: 0.17,
      width: 2.0 + 1.2 * energy,
      headColor: Colors.white,
      tailColor: theme.accent,
    );
    _drawComet(
      canvas,
      metric,
      total,
      head: (head + total * 0.5) % total,
      tailFraction: 0.09,
      width: 1.5,
      headColor: Colors.white,
      tailColor: theme.accent2,
    );

    // 5) Başlanğıc nöqtəsi (yuxarı mərkəz).
    final Offset start = Offset(size.width / 2, 0.75);
    canvas.drawCircle(
      start,
      3.4 + 2.2 * pu + 3 * energy,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.white.withValues(alpha: 0.25 + 0.35 * (1 - pu) + 0.3 * energy),
    );
    canvas.drawCircle(
      start,
      2.0 + 1.6 * energy,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  void _drawComet(
    Canvas canvas,
    ui.PathMetric metric,
    double total, {
    required double head,
    required double tailFraction,
    required double width,
    required Color headColor,
    required Color tailColor,
  }) {
    const int segments = 30;
    final double segLen = total * tailFraction / segments;

    for (int k = 0; k < segments; k++) {
      final double a = head - (k + 1) * segLen;
      final double b = head - k * segLen;
      final double f = 1 - k / segments;

      canvas.drawPath(
        _segment(metric, total, a, b),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = width * (0.30 + 0.70 * f)
          ..color = Color.lerp(tailColor, headColor, f * f)!
              .withValues(alpha: (f * f).clamp(0.0, 1.0)),
      );
    }

    final ui.Tangent? tangent = metric.getTangentForOffset(head.clamp(0.0, total));
    if (tangent != null) {
      canvas.drawCircle(
        tangent.position,
        width * 0.9,
        Paint()..color = headColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitBorderPainter oldDelegate) {
    return oldDelegate.theme != theme || oldDelegate.radius != radius;
  }
}

// ============================================================================
// YENİ KART YARANARKƏN: xətt özü-özünü çəkir
// ============================================================================
class _BuildRingPainter extends CustomPainter {
  _BuildRingPainter({
    required this.progress,
    required this.theme,
    required this.radius,
  });

  final double progress;
  final _CardTheme theme;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final Path path = _borderPath(size, radius);
    final ui.PathMetric metric = path.computeMetrics().first;
    final double total = metric.length;

    final double draw = Curves.easeInOutCubic.transform((progress / 0.8).clamp(0.0, 1.0));
    final double head = total * draw;

    if (head > 0.5) {
      canvas.drawPath(
        metric.extractPath(0, head),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.6
          ..shader = LinearGradient(
            colors: <Color>[theme.accent2, theme.accent, Colors.white],
          ).createShader(Offset.zero & size),
      );

      final ui.Tangent? tangent = metric.getTangentForOffset(head);
      if (tangent != null && progress < 0.8) {
        canvas.drawCircle(
          tangent.position,
          3.0,
          Paint()..color = Colors.white,
        );
      }
    }

    // Xətt tamamlanandan sonra bütün kənar parlayıb sönür.
    if (progress > 0.8) {
      final double f = 1 - ((progress - 0.8) / 0.2).clamp(0.0, 1.0);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 + 1.4 * f
          ..color = Colors.white.withValues(alpha: 0.85 * f),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BuildRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.theme != theme;
  }
}

// ============================================================================
// GƏZƏN İŞIQ ZOLAĞI (orbit dövrünün müəyyən anlarında)
// ============================================================================
class _ShinePainter extends CustomPainter {
  _ShinePainter({required this.orbit}) : super(repaint: orbit);

  final Animation<double> orbit;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final double v = orbit.value;
    double t = -1;
    if (v >= 0.12 && v <= 0.30) {
      t = (v - 0.12) / 0.18;
    } else if (v >= 0.58 && v <= 0.74) {
      t = (v - 0.58) / 0.16;
    }
    if (t < 0) return;

    final double x = -size.width * 0.3 + size.width * 1.6 * Curves.easeInOut.transform(t);
    final double skew = size.height * 0.5;
    const double band = 74;

    canvas.save();
    canvas.translate(x, 0);

    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(band, 0)
      ..lineTo(band - skew, size.height)
      ..lineTo(-skew, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.24),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(-skew, 0, band + skew, size.height)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShinePainter oldDelegate) => false;
}

// ============================================================================
// NAXIŞ (hər temada fərqli, statik)
// ============================================================================
class _PatternPainter extends CustomPainter {
  _PatternPainter({
    required this.kind,
    required this.line,
    required this.accent,
  });

  final _PatternKind kind;
  final Color line;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case _PatternKind.circles:
        _paintCircles(canvas, size);
        break;
      case _PatternKind.waves:
        _paintWaves(canvas, size);
        break;
      case _PatternKind.dots:
        _paintDots(canvas, size);
        break;
      case _PatternKind.stripes:
        _paintStripes(canvas, size);
        break;
    }
  }

  Paint get _stroke => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..color = line;

  void _paintCircles(Canvas canvas, Size size) {
    final Offset origin = Offset(size.width, 0);
    for (int i = 1; i <= 6; i++) {
      canvas.drawCircle(origin, 36.0 + i * 34, _stroke);
    }
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height),
      54,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = accent,
    );
  }

  void _paintWaves(Canvas canvas, Size size) {
    for (int i = 0; i < 5; i++) {
      final double baseY = size.height * (0.45 + i * 0.12);
      final Path path = Path()..moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 6) {
        final double y = baseY + math.sin((x / size.width) * math.pi * 3 + i) * 9;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, i == 2 ? (Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = accent) : _stroke);
    }
  }

  void _paintDots(Canvas canvas, Size size) {
    const double gap = 17;
    for (double x = gap; x < size.width; x += gap) {
      final double fade = (x / size.width).clamp(0.0, 1.0);
      for (double y = gap; y < size.height; y += gap) {
        canvas.drawCircle(
          Offset(x, y),
          1.2,
          Paint()..color = line.withValues(alpha: 0.05 + 0.18 * fade),
        );
      }
    }
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      3.2,
      Paint()..color = accent,
    );
  }

  void _paintStripes(Canvas canvas, Size size) {
    const double gap = 22;
    for (double d = -size.height; d < size.width; d += gap) {
      canvas.drawLine(
        Offset(d, size.height),
        Offset(d + size.height, 0),
        _stroke,
      );
    }
    canvas.drawLine(
      Offset(size.width * 0.55, size.height),
      Offset(size.width * 0.55 + size.height, 0),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = accent,
    );
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.line != line ||
        oldDelegate.accent != accent;
  }
}

// ============================================================================
// PARÇALAR (kartın real şəkli üçbucaq parçalara bölünür)
// ============================================================================
class _Shard {
  _Shard({
    required this.points,
    required this.centroid,
    required this.velocity,
    required this.spin,
    required this.delay,
    required this.depth,
  }) : path = _buildPath(points);

  final List<Offset> points;
  final Offset centroid;
  final Offset velocity;
  final double spin;
  final double delay;
  final double depth;
  final Path path;

  static Path _buildPath(List<Offset> points) {
    final Path p = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      p.lineTo(points[i].dx, points[i].dy);
    }
    return p..close();
  }

  static List<_Shard> generate(
    Size size,
    math.Random random, {
    int cols = 7,
    int rows = 4,
  }) {
    final double cw = size.width / cols;
    final double ch = size.height / rows;

    // Qaydasız (jitter) şəbəkə nöqtələri.
    final List<List<Offset>> grid = List<List<Offset>>.generate(rows + 1, (int r) {
      return List<Offset>.generate(cols + 1, (int c) {
        double x = c * cw;
        double y = r * ch;
        if (c > 0 && c < cols) x += (random.nextDouble() - 0.5) * cw * 0.7;
        if (r > 0 && r < rows) y += (random.nextDouble() - 0.5) * ch * 0.7;
        return Offset(x, y);
      });
    });

    // Partlayış mərkəzi: kartın ortasına yaxın.
    final Offset origin = Offset(
      size.width * (0.42 + random.nextDouble() * 0.16),
      size.height * (0.40 + random.nextDouble() * 0.20),
    );
    final double maxDist = math.sqrt(
      size.width * size.width / 4 + size.height * size.height / 4,
    );

    final List<_Shard> shards = <_Shard>[];

    void add(Offset a, Offset b, Offset c) {
      final Offset centroid = Offset(
        (a.dx + b.dx + c.dx) / 3,
        (a.dy + b.dy + c.dy) / 3,
      );

      Offset dir = centroid - origin;
      final double dist = dir.distance;
      if (dist < 1) {
        final double angle = random.nextDouble() * math.pi * 2;
        dir = Offset(math.cos(angle), math.sin(angle));
      } else {
        dir = dir / dist;
      }

      final double speed = (170 + random.nextDouble() * 360) *
          (1 - 0.35 * (dist / maxDist).clamp(0.0, 1.0));

      shards.add(
        _Shard(
          points: <Offset>[a, b, c],
          centroid: centroid,
          velocity: dir * speed + Offset(0, -70 * random.nextDouble()),
          spin: (random.nextDouble() - 0.5) * 9,
          delay: (dist / maxDist).clamp(0.0, 1.0) * 0.22,
          depth: 0.4 + random.nextDouble() * 0.9,
        ),
      );
    }

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final Offset tl = grid[r][c];
        final Offset tr = grid[r][c + 1];
        final Offset bl = grid[r + 1][c];
        final Offset br = grid[r + 1][c + 1];

        if ((r + c).isEven) {
          add(tl, tr, br);
          add(tl, br, bl);
        } else {
          add(tl, tr, bl);
          add(tr, br, bl);
        }
      }
    }

    return shards;
  }
}

// ============================================================================
// QIĞILCIMLAR
// ============================================================================
class _Spark {
  const _Spark({
    required this.direction,
    required this.speed,
    required this.size,
    required this.delay,
    required this.colorIndex,
  });

  final Offset direction;
  final double speed;
  final double size;
  final double delay;
  final int colorIndex;

  static List<_Spark> generate(math.Random random, {int count = 90}) {
    return List<_Spark>.generate(count, (int i) {
      final double angle = random.nextDouble() * math.pi * 2;
      return _Spark(
        direction: Offset(math.cos(angle), math.sin(angle)),
        speed: 140 + random.nextDouble() * 420,
        size: 1.2 + random.nextDouble() * 2.4,
        delay: random.nextDouble() * 0.12,
        colorIndex: random.nextInt(3),
      );
    });
  }
}

// ============================================================================
// PARTLAYIŞ RƏSMİ (flash + şok dalğası + parçalar + qığılcımlar)
// ============================================================================
class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.progress,
    required this.shards,
    required this.sparks,
    required this.image,
    required this.theme,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final List<_Shard> shards;
  final List<_Spark> sparks;
  final ui.Image? image;
  final _CardTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final double t = progress.value;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect full = Offset.zero & size;

    _paintFlash(canvas, center, size, t);
    _paintShockwave(canvas, center, size, t);
    _paintShards(canvas, full, t);
    _paintSparks(canvas, center, t);
  }

  void _paintFlash(Canvas canvas, Offset center, Size size, double t) {
    if (t >= 0.28) return;
    final double f = 1 - t / 0.28;
    final double radius = 120 + size.width * 0.35 * (1 - f);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: 0.65 * f),
            theme.accent.withValues(alpha: 0.25 * f),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const <double>[0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  void _paintShockwave(Canvas canvas, Offset center, Size size, double t) {
    final double radius = Curves.easeOutCubic.transform(t) * size.longestSide * 0.95;
    final double alpha = (1 - t).clamp(0.0, 1.0);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6 * alpha + 0.4
        ..color = theme.accent.withValues(alpha: 0.75 * alpha),
    );
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2 * alpha + 0.2
        ..color = Colors.white.withValues(alpha: 0.5 * alpha),
    );
  }

  void _paintShards(Canvas canvas, Rect full, double t) {
    final ui.Image? img = image;

    for (final _Shard shard in shards) {
      final double local = ((t - shard.delay) / (1 - shard.delay)).clamp(0.0, 1.0);
      final double move = Curves.easeOutCubic.transform(local);

      final Offset offset = shard.velocity * move + Offset(0, 430 * local * local);
      final double angle = shard.spin * move;
      final double scale = 1 + 0.30 * shard.depth * move;
      final double alpha = local < 0.45
          ? 1.0
          : (1 - ((local - 0.45) / 0.55)).clamp(0.0, 1.0);

      if (alpha <= 0.01) continue;

      canvas.save();
      canvas.translate(
        shard.centroid.dx + offset.dx,
        shard.centroid.dy + offset.dy,
      );
      canvas.rotate(angle);
      canvas.scale(scale);
      canvas.translate(-shard.centroid.dx, -shard.centroid.dy);

      canvas.save();
      canvas.clipPath(shard.path);
      if (img != null) {
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          full,
          Paint()
            ..filterQuality = FilterQuality.medium
            ..color = Colors.white.withValues(alpha: alpha),
        );
      } else {
        canvas.drawRect(
          full,
          Paint()..color = theme.colors[1].withValues(alpha: alpha),
        );
      }
      canvas.restore();

      // Parçanın parlayan kənarı.
      canvas.drawPath(
        shard.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..color = Colors.white.withValues(alpha: 0.55 * alpha),
      );
      canvas.restore();
    }
  }

  void _paintSparks(Canvas canvas, Offset center, double t) {
    final List<Color> palette = <Color>[Colors.white, theme.accent, theme.accent2];

    for (final _Spark spark in sparks) {
      final double local = ((t - spark.delay) / (1 - spark.delay)).clamp(0.0, 1.0);
      if (local <= 0 || local >= 1) continue;

      final double move = Curves.easeOutCubic.transform(local);
      final double prevMove = Curves.easeOutCubic.transform((local - 0.07).clamp(0.0, 1.0));

      final Offset pos = center +
          spark.direction * (spark.speed * move) +
          Offset(0, 95 * local * local);
      final Offset prev = center +
          spark.direction * (spark.speed * prevMove) +
          Offset(0, 95 * (local - 0.07).clamp(0.0, 1.0) * (local - 0.07).clamp(0.0, 1.0));

      final double alpha = math.pow(1 - local, 1.2).toDouble();
      final Color color = palette[spark.colorIndex].withValues(alpha: alpha);

      canvas.drawLine(
        prev,
        pos,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = spark.size
          ..color = color,
      );
      canvas.drawCircle(pos, spark.size * 0.55, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) {
    return oldDelegate.shards != shards ||
        oldDelegate.sparks != sparks ||
        oldDelegate.image != image ||
        oldDelegate.theme != theme;
  }
}