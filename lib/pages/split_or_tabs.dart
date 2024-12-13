import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';

class SplitOrTabs extends StatefulWidget {
  const SplitOrTabs({required this.tabs, required this.children, super.key});
  final List<Widget> tabs;
  final List<Widget> children;

  @override
  State<SplitOrTabs> createState() => _SplitOrTabsState();
}

class _SplitOrTabsState extends State<SplitOrTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MediaQuery.of(context).size.width > 800
      ? SplitView(
          controller: SplitViewController(
            weights: [0.3, 0.7],
            limits: [WeightLimit(min: 0.2), WeightLimit(min: 0.4)],
          ),
          viewMode: SplitViewMode.Horizontal,
          gripColor: Colors.transparent,
          indicator: const SplitIndicator(
            viewMode: SplitViewMode.Horizontal,
            color: Colors.grey,
          ),
          gripColorActive: Colors.transparent,
          activeIndicator: const SplitIndicator(
            viewMode: SplitViewMode.Horizontal,
            isActive: true,
            color: Colors.black,
          ),
          children: widget.children,
        )
      : Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: widget.tabs,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: widget.children,
              ),
            ),
          ],
        );
}
