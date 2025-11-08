import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../themes/text_field_widget.dart';

class AnimatedSearchHint extends StatefulWidget {
  final TextEditingController? controller;
  final Widget? prefix;
  final Widget? suffix;
  final bool? enable;
  final bool? obscureText;
  final int? maxLine;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onchange;
  final TextInputAction? textInputAction;
  final String? fontFamily;
  final Color? fillColor;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;
  final List<String>? hints;
  final Duration? interval;

  const AnimatedSearchHint({
    Key? key,
    this.controller,
    this.prefix,
    this.suffix,
    this.enable,
    this.obscureText,
    this.maxLine,
    this.textInputType,
    this.inputFormatters,
    this.onchange,
    this.textInputAction,
    this.fontFamily,
    this.fillColor,
    this.textStyle,
    this.hintTextStyle,
    this.hints,
    this.interval,
  }) : super(key: key);

  @override
  State<AnimatedSearchHint> createState() => _AnimatedSearchHintState();
}

class _AnimatedSearchHintState extends State<AnimatedSearchHint>
    with TickerProviderStateMixin {
  late final List<String> _hints;
  late final List<String> _emojis;
  int _currentHint = 0;
  Timer? _timer;
  bool _controllersInitialized = false;
  
  // Animation controllers
  late AnimationController _textAnimationController;
  late AnimationController _emojiAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _glowAnimationController;
  AnimationController? _typewriterController;
  AnimationController? _colorController;
  
  // Animations
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _emojiBounceAnimation;
  late Animation<double> _emojiRotateAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  Animation<double>? _typewriterAnimation;
  Animation<Color?>? _textColorAnimation;

  @override
  void initState() {
    super.initState();
    
    _hints = widget.hints ?? [
      // Food items
      "Search '🍰 cake'",
      "Search '🍛 biryani'",
      "Search '🍦 ice cream'",
      "Search '🍕 pizza'",
      "Search '🍔 burger'",
      "Search '🍣 sushi'",
      "Search '🍴 restaurants'",
      "Search '🥘 curry'",
      "Search '🍜 noodles'",
      "Search '🌮 tacos'",
      "Search '🍗 chicken'",
      "Search '🥗 salad'",
      "Search '🍳 breakfast'",
      "Search '🍝 pasta'",
      "Search '🍲 soup'",
      "Search '🥙 wraps'",
      "Search '🍩 donuts'",
      "Search '☕ coffee'",
      "Search '🍪 cookies'",
      "Search '🥤 drinks'",
      
      // Motivational messages
      "Search '💪 healthy food'",
      "Search '🌟 trending dishes'",
      "Search '🔥 popular items'",
      "Search '⭐ top rated'",
      "Search '🚀 new arrivals'",
      "Search '💎 premium'",
      "Search '🎯 best deals'",
      "Search '🏆 award winning'",
      "Search '✨ special offers'",
      "Search '🎉 today's special'",
      "Search '💝 gift ideas'",
      "Search '🌙 late night'",
      "Search '☀️ breakfast'",
      "Search '🌅 morning'",
      "Search '🌆 evening'",
      "Search '🌃 dinner'",
      "Search '🍽️ family meals'",
      "Search '👥 group orders'",
      "Search '💼 office lunch'",
      "Search '🎊 party food'",
    ];
    
    _emojis = [
      // Food emojis
      "🍰", "🍛", "🍦", "🍕", "🍔", "🍣", "🍴", "🥘", "🍜", "🌮", "🍗", "🥗",
      "🍳", "🍝", "🍲", "🥙", "🍩", "☕", "🍪", "🥤",
      // Motivational emojis
      "💪", "🌟", "🔥", "⭐", "🚀", "💎", "🎯", "🏆", "✨", "🎉", "💝", "🌙",
      "☀️", "🌅", "🌆", "🌃", "🍽️", "👥", "💼", "🎊"
    ];
    
    // Initialize animation controllers
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _emojiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _glowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _typewriterController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Initialize animations
    _textSlideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _emojiBounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _emojiAnimationController,
      curve: Curves.bounceOut,
    ));
    
    _emojiRotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _emojiAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _typewriterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typewriterController!,
      curve: Curves.easeInOut,
    ));
    
    _textColorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.orange,
    ).animate(CurvedAnimation(
      parent: _colorController!,
      curve: Curves.easeInOut,
    ));
    
    // Start animations after a small delay to ensure everything is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _controllersInitialized = true;
      });
      
      // Start continuous animations (removed pulse animation)
      _glowAnimationController.repeat(reverse: true);
      _colorController?.repeat(reverse: true);
      
      // Start text animation
      _textAnimationController.forward();
      _emojiAnimationController.forward();
      _typewriterController?.forward();
    });
    
    // Timer for changing hints
    _timer = Timer.periodic(widget.interval ?? const Duration(seconds: 3), (timer) {
      _changeHint();
    });
  }

  void _changeHint() {
    setState(() {
      _currentHint = (_currentHint + 1) % _hints.length;
    });
    
    // Restart animations
    _textAnimationController.reset();
    _emojiAnimationController.reset();
    _typewriterController?.reset();
    _textAnimationController.forward();
    _emojiAnimationController.forward();
    _typewriterController?.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textAnimationController.dispose();
    _emojiAnimationController.dispose();
    _pulseAnimationController.dispose();
    _glowAnimationController.dispose();
    _typewriterController?.dispose();
    _colorController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safety check to ensure controllers are initialized
    if (!_controllersInitialized) {
      return TextFieldWidget(
        hintText: _hints[_currentHint],
        controller: widget.controller,
        enable: widget.enable,
        prefix: widget.prefix,
        suffix: widget.suffix,
        obscureText: widget.obscureText,
        maxLine: widget.maxLine,
        textInputType: widget.textInputType,
        inputFormatters: widget.inputFormatters,
        onchange: widget.onchange,
        textInputAction: widget.textInputAction,
        fontFamily: widget.fontFamily,
        fillColor: widget.fillColor,
        textStyle: widget.textStyle,
        hintTextStyle: widget.hintTextStyle,
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _textAnimationController,
        _emojiAnimationController,
        _glowAnimationController,
        if (_typewriterController != null) _typewriterController!,
        if (_colorController != null) _colorController!,
      ]),
      builder: (context, child) {
        // Additional safety check inside the builder
        if (!_controllersInitialized) {
          return TextFieldWidget(
            hintText: _hints[_currentHint],
            controller: widget.controller,
            enable: widget.enable,
            prefix: widget.prefix,
            suffix: widget.suffix,
            obscureText: widget.obscureText,
            maxLine: widget.maxLine,
            textInputType: widget.textInputType,
            inputFormatters: widget.inputFormatters,
            onchange: widget.onchange,
            textInputAction: widget.textInputAction,
            fontFamily: widget.fontFamily,
            fillColor: widget.fillColor,
            textStyle: widget.textStyle,
            hintTextStyle: widget.hintTextStyle,
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white, // ✅ gives visible white background
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              // 👇 Soft base shadow for consistent elevation
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              // 👇 Animated orange glow (gentle)
              BoxShadow(
                color: Colors.black.withOpacity(0.25 * _glowAnimation.value),
                blurRadius: 25 * _glowAnimation.value,
                spreadRadius: 3 * _glowAnimation.value,
              ),
            ],
          ),
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(12),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.orange.withOpacity(0.1 * _glowAnimation.value),
          //       blurRadius: 15 * _glowAnimation.value,
          //       spreadRadius: 2 * _glowAnimation.value,
          //     ),
          //   ],
          // ),
          child:  ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                TextFieldWidget(
                  key: ValueKey(_hints[_currentHint]),
                  hintText: "", // Empty hint text, we'll overlay our custom text
                  controller: widget.controller,
                  enable: widget.enable,
                  prefix: _buildAnimatedPrefix(),
                  suffix: _buildAnimatedSuffix(),
                  obscureText: widget.obscureText,
                  maxLine: widget.maxLine,
                  textInputType: widget.textInputType,
                  inputFormatters: widget.inputFormatters,
                  onchange: widget.onchange,
                  textInputAction: widget.textInputAction,
                  fontFamily: widget.fontFamily,
                  fillColor: widget.fillColor,
                  textStyle: widget.textStyle,
                  hintTextStyle: widget.hintTextStyle,
                ),
                // Custom animated hint text overlay
                if (widget.controller?.text.isEmpty ?? true)
                  Positioned.fill(
                    child: _buildAnimatedHintText(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedPrefix() {
    // Safety check for animation controllers
    if (!_controllersInitialized) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: Text(
          _emojis[_currentHint % _emojis.length],
          style: const TextStyle(fontSize: 18),
        ),
      );
    }

    return Transform.translate(
      offset: Offset(0, _textSlideAnimation.value),
      child: Opacity(
        opacity: _textFadeAnimation.value,
        child: Transform.scale(
          scale: _emojiBounceAnimation.value,
          child: Transform.rotate(
            angle: _emojiRotateAnimation.value * 0.1,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Text(
                _emojis[_currentHint % _emojis.length],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSuffix() {
    // Safety check for animation controllers
    if (!_controllersInitialized) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SvgPicture.asset(
          "assets/icons/ic_search.svg",
          color: Color(0xFFff5201),
        ),
      );
    }

    return Transform.translate(
      offset: Offset(0, _textSlideAnimation.value * 0.5),
      child: Opacity(
        opacity: _textFadeAnimation.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SvgPicture.asset(
            "assets/icons/ic_search.svg",
            color: Color(0xFFff5201).withOpacity(0.7 + (0.3 * _glowAnimation.value)),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHintText() {
    if (!_controllersInitialized) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Text(
          _hints[_currentHint],
          style: widget.hintTextStyle,
        ),
      );
    }

    final currentHint = _hints[_currentHint];
    
    // Split the hint into "Search" (static) and the changing part
    String staticPart = "Search ";
    String changingPart = currentHint.replaceFirst("Search ", " ");
    
    // Calculate visible length for the changing part only
    final visibleLength = (changingPart.length * (_typewriterAnimation?.value ?? 1.0)).round();
    final visibleChangingText = changingPart.substring(0, visibleLength.clamp(0, changingPart.length));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Add spacing for emoji
          const SizedBox(width: 28   ),
          // Animated text with typewriter effect
          Expanded(
            child: Transform.translate(
              offset: Offset(0, _textSlideAnimation.value),
              child: Opacity(
                opacity: _textFadeAnimation.value,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: (widget.hintTextStyle ?? const TextStyle()).copyWith(
                    color: _textColorAnimation?.value ?? Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        // Static "Search" part
                        TextSpan(
                          text: staticPart,
                          style: (widget.hintTextStyle ?? const TextStyle()).copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Animated changing part
                        TextSpan(
                          text: visibleChangingText,
                          style: (widget.hintTextStyle ?? const TextStyle()).copyWith(
                            color: _textColorAnimation?.value ?? Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Animated cursor - Removed to avoid showing "|" symbol
          // if ((_typewriterAnimation?.value ?? 1.0) < 1.0)
          //   Transform.translate(
          //     offset: Offset(0, _textSlideAnimation.value),
          //     child: Opacity(
          //       opacity: _textFadeAnimation.value,
          //       child: AnimatedBuilder(
          //         animation: _typewriterController ?? _textAnimationController,
          //         builder: (context, child) {
          //           return Container(
          //             width: 2,
          //             height: 20,
          //             decoration: BoxDecoration(
          //               color: _textColorAnimation?.value ?? Colors.grey,
          //               borderRadius: BorderRadius.circular(1),
          //             ),
          //             child: AnimatedOpacity(
          //               duration: const Duration(milliseconds: 500),
          //               opacity: ((_typewriterController?.value ?? 1.0) * 10) % 2 < 1 ? 1.0 : 0.0,
          //               child: Container(),
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
} 