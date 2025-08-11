import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  // Dart 3 레코드 타입 명시
  static const List<(String, String)> _tabs = <(String, String)>[
    ('Home', '/home'),
    ('Shops', '/shops'),
    ('Events', '/events'),
    ('Contact', '/contact'),
  ];

  bool _isActive(BuildContext context, String route) {
    // ✅ go_router 14: 현재 경로는 GoRouterState에서 얻는다
    final loc = GoRouterState.of(context).uri.toString();
    return loc == route || loc.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      // 모바일: Drawer 사용
      drawer: isWide
          ? null
          : Drawer(
              child: SafeArea(
                child: ListView(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.school),
                      title: Text(
                        'Soonchunhyang University',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    ..._tabs.map(
                      (t) => ListTile(
                        leading: Icon(_iconFor(t.$2)),
                        title: Text(t.$1),
                        selected: _isActive(context, t.$2),
                        onTap: () {
                          Navigator.pop(context);
                          context.go(t.$2);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

      appBar: AppBar(
        elevation: 0,
        titleSpacing: 16,
        // Drawer가 있을 때는 leading=null 이어야 햄버거가 자동 표시됨
        leading: isWide ? const Icon(Icons.school) : null,
        title: Row(
          children: [
            if (isWide)
              const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Text(
                  'Soonchunhyang University',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        actions: [
          if (isWide)
            Row(
              children: [
                ..._tabs.map(
                  (t) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: TextButton(
                      onPressed: () => context.go(t.$2),
                      style: TextButton.styleFrom(
                        foregroundColor: _isActive(context, t.$2)
                            ? Colors.black
                            : Colors.black54,
                        overlayColor: Colors.black12,
                      ),
                      child: Text(
                        t.$1,
                        style: TextStyle(
                          fontWeight: _isActive(context, t.$2)
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: child,
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String r) {
    switch (r) {
      case '/home':
        return Icons.home_outlined;
      case '/shops':
        return Icons.storefront_outlined;
      case '/events':
        return Icons.event_outlined;
      case '/contact':
        return Icons.contact_mail_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}
