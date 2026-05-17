import 'package:flutter/material.dart';

/// Thin wrapper around `Scaffold` that:
///   - applies a consistent SafeArea + horizontal padding
///   - centers body content on wider screens (doctor web view)
///   - exposes a `topBar` slot that respects the theme's `AppBarTheme`
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.actions = const <Widget>[],
    this.leading,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.horizontalPadding = 20,
    this.maxContentWidth = 720,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  final Widget body;
  final String? title;
  final List<Widget> actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final double horizontalPadding;
  final double maxContentWidth;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              leading: leading,
              actions: actions,
            ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}
