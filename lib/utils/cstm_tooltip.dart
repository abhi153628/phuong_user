import 'package:flutter/material.dart';

class TapTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final TextStyle textStyle;
  final BoxDecoration decoration;
  final EdgeInsets padding;
  final Duration displayDuration;

  const TapTooltip({
    Key? key,
    required this.child,
    required this.message,
    this.textStyle = const TextStyle(color: Colors.white, fontSize: 14),
    this.decoration = const BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.padding = const EdgeInsets.all(8),
    this.displayDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  _TapTooltipState createState() => _TapTooltipState();
}

class _TapTooltipState extends State<TapTooltip> {
  OverlayEntry? _overlayEntry;

  void _showTooltip() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final targetOffset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: targetOffset.dx,
        top: targetOffset.dy - size.height - 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: widget.padding,
            decoration: widget.decoration,
            child: Text(
              widget.message,
              style: widget.textStyle,
            ),
          ),
        ),
      ),
    );

    overlay?.insert(_overlayEntry!);

    Future.delayed(widget.displayDuration, () => _hideTooltip());
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTooltip,
      child: widget.child,
    );
  }
}
