import 'package:flutter/material.dart';


/// Mixin for screens that use TabController to avoid code duplication
mixin TabControllerMixin<T extends StatefulWidget> on State<T> {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: getTabCount(),
      vsync: this,
      initialIndex: getInitialTabIndex(),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  /// Override to specify number of tabs
  int getTabCount();

  /// Override to specify initial tab index (defaults to 0)
  int getInitialTabIndex() => 0;
}
