import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class Scaffold extends StatefulWidget {
  final List<Widget> headers;
  final List<Widget> footers;
  final Widget child;
  final double? loadingProgress;
  final bool loadingProgressIndeterminate;
  final VoidCallback? onRefresh;
  final bool
      floatingHeader; // when header floats, it takes no space in the layout, and positioned on top of the content
  final bool floatingFooter;
  final Color? headerBackgroundColor;
  final Color? footerBackgroundColor;
  final bool showLoadingSparks;

  const Scaffold({
    super.key,
    required this.child,
    this.headers = const [],
    this.footers = const [],
    this.loadingProgress,
    this.loadingProgressIndeterminate = false,
    this.onRefresh,
    this.floatingHeader = false,
    this.floatingFooter = false,
    this.headerBackgroundColor,
    this.footerBackgroundColor,
    this.showLoadingSparks = false,
  });

  @override
  State<Scaffold> createState() => ScaffoldState();
}

class ScaffoldState extends State<Scaffold> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DrawerOverlay(
      child: AnimatedContainer(
        duration: kDefaultDuration,
        color: theme.colorScheme.background,
        child: _ScaffoldFlex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: widget.headerBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    verticalDirection: VerticalDirection.up,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.loadingProgress != null ||
                          widget.loadingProgressIndeterminate)
                        SizedBox(
                          // to make it float
                          height: 0,
                          child: Stack(
                            clipBehavior: Clip.none,
                            fit: StackFit.passthrough,
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                  value: widget.loadingProgressIndeterminate
                                      ? null
                                      : widget.loadingProgress,
                                  showSparks: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: widget.headers,
                      ),
                    ],
                  ),
                  if (widget.loadingProgress != null &&
                      widget.showLoadingSparks)
                    SizedBox(
                      // to make it float
                      height: 0,
                      child: Stack(
                        clipBehavior: Clip.none,
                        fit: StackFit.passthrough,
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              value: widget.loadingProgressIndeterminate
                                  ? null
                                  : widget.loadingProgress,
                              showSparks: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: widget.child,
            ),
            Container(
              color: widget.footerBackgroundColor,
              child: Column(
                children: widget.footers,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBar extends StatefulWidget {
  final List<Widget> trailing;
  final List<Widget> leading;
  final Widget? child;
  final Widget? title;
  final Widget? header; // small widget placed on top of title
  final Widget? subtitle; // small widget placed below title
  final bool
      trailingExpanded; // expand the trailing instead of the main content
  final Alignment alignment;
  final Color? backgroundColor;
  final double leadingGap;
  final double trailingGap;
  final EdgeInsetsGeometry? padding;
  final double? height;

  const AppBar({
    super.key,
    this.trailing = const [],
    this.leading = const [],
    this.title,
    this.header,
    this.subtitle,
    this.child,
    this.trailingExpanded = false,
    this.alignment = Alignment.center,
    this.padding,
    this.backgroundColor,
    this.leadingGap = 8,
    this.trailingGap = 8,
    this.height,
  }) : assert(
          child == null || title == null,
          'Cannot provide both child and title',
        );

  @override
  State<AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<AppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FocusTraversalGroup(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: widget.backgroundColor ??
                theme.colorScheme.background.withOpacity(0.4),
            alignment: widget.alignment,
            height: widget.height,
            padding: widget.padding ??
                const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 8,
                ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.leading,
                  ).gap(widget.leadingGap),
                  const Gap(16),
                  Flexible(
                    fit:
                        widget.trailingExpanded ? FlexFit.loose : FlexFit.tight,
                    child: widget.child ??
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.header != null)
                              widget.header!.muted().base(),
                            if (widget.title != null) widget.title!.large(),
                            if (widget.subtitle != null)
                              widget.subtitle!.muted().small(),
                          ],
                        ),
                  ),
                  const Gap(16),
                  if (!widget.trailingExpanded)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.trailing,
                    ).gap(widget.trailingGap)
                  else
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: widget.trailing,
                      ).gap(widget.trailingGap),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScaffoldFlex extends Flex {
  const _ScaffoldFlex({
    super.direction = Axis.vertical,
    super.crossAxisAlignment = CrossAxisAlignment.center,
    super.children = const <Widget>[],
  });

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return _ScaffoldRenderFlex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection ?? Directionality.of(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior,
    );
  }
}

class _ScaffoldRenderFlex extends RenderFlex {
  _ScaffoldRenderFlex({
    super.direction = Axis.vertical,
    super.mainAxisAlignment = MainAxisAlignment.start,
    super.mainAxisSize = MainAxisSize.max,
    super.crossAxisAlignment = CrossAxisAlignment.center,
    super.textDirection,
    super.verticalDirection = VerticalDirection.down,
    super.textBaseline,
    super.clipBehavior = Clip.none,
  });

  @override
  void defaultPaint(PaintingContext context, Offset offset) {
    // There is gonna be only 3 children
    // 1. header
    // 2. content
    // 3. footer
    // By default, the paint order is 1, 2, 3
    // but with this custom implementation, we can change the order to 2, 1, 3
    // which means the header will be painted after the content
    // and the footer will be painted after the header
    RenderBox header = firstChild!;
    RenderBox content = (header.parentData as FlexParentData).nextSibling!;
    RenderBox footer = (content.parentData as FlexParentData).nextSibling!;
    context.paintChild(
        content, (content.parentData as BoxParentData).offset + offset);
    context.paintChild(
        header, (header.parentData as BoxParentData).offset + offset);
    context.paintChild(
        footer, (footer.parentData as BoxParentData).offset + offset);
  }
}
