import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        height: 1,
        thickness: 1,
        indent: -4,
        endIndent: -4,
        color: theme.colorScheme.border,
      ),
    );
  }
}

class MenuButton extends StatefulWidget {
  final Widget child;
  final List<Widget>? subMenu;
  final VoidCallback? onPressed;
  final Widget? trailing;
  final Widget? leading;
  final bool enabled;
  final FocusNode? focusNode;

  MenuButton({
    required this.child,
    this.subMenu,
    this.onPressed,
    this.trailing,
    this.leading,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  final PopoverController _popoverController = PopoverController();

  void openSubMenu() {}

  @override
  Widget build(BuildContext context) {
    final menuBarData = Data.maybeOf<MenubarState>(context);
    final menuData = Data.maybeOf<MenuData>(context);
    assert(menuData != null || menuBarData != null,
        'MenuButton must be a descendant of Menubar or Menu');
    final data = menuBarData ?? menuData!;
    return Data<MenuData>.boundary(
      child: Data<MenubarState>.boundary(
        child: PopoverPortal(
          controller: _popoverController,
          child: Button(
            style: menuBarData == null
                ? ButtonVariance.menu
                : ButtonVariance.menubar,
            trailing: widget.trailing,
            leading: widget.leading,
            disableTransition: true,
            enabled: widget.enabled,
            onHover: (value) {},
            onPressed: () {
              widget.onPressed?.call();
              if (widget.subMenu != null) {
                _popoverController.show(
                  key: data.popupKey,
                  builder: (context) {
                    return MenuGroup(
                        dataBuilder: () => MenuData(),
                        children: widget.subMenu!,
                        builder: (context, children) {
                          return MenuPopup(
                            children: children,
                          );
                        });
                  },
                  alignment: Alignment.topLeft,
                  anchorAlignment: Alignment.topRight,
                  offset: const Offset(4, 0),
                  closeOthers: true,
                );
              }
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class MenuData {
  final GlobalKey<PopoverAnchorState> popupKey = GlobalKey();
}

class MenuGroup extends StatefulWidget {
  final PopoverController? popoverController;
  final List<Widget> children;
  final Widget Function(BuildContext context, List<Widget> children) builder;

  MenuGroup({
    super.key,
    required this.children,
    required this.builder,
    this.popoverController,
  });

  @override
  State<MenuGroup> createState() => _MenuGroupState();
}

class _MenuGroupState extends State<MenuGroup> {
  late List<MenuData> _data;

  @override
  void initState() {
    super.initState();
    _data = List.generate(widget.children.length, (i) {
      return MenuData();
    });
  }

  @override
  void didUpdateWidget(covariant MenuGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.children, widget.children)) {
      _data = List.generate(widget.children.length, (i) {
        return MenuData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int i = 0; i < widget.children.length; i++) {
      final child = widget.children[i];
      final data = _data[i];
      children.add(
        Data<MenuData>(
          data: data,
          child: child,
        ),
      );
    }
    return widget.builder(context, children);
  }
}
