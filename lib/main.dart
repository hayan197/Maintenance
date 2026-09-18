import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/orders_provider.dart';
import 'screens/login_screen.dart';
import 'screens/orders_list_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/orders_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FixFlowApp());
}

class FixFlowApp extends StatelessWidget {
  const FixFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final authService = AuthService(apiClient);
    final ordersService = OrdersService(apiClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)..tryAutoLogin()),
        ChangeNotifierProvider(create: (_) => OrdersProvider(ordersService)),
      ],
      child: MaterialApp(
        title: 'FixFlow',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: _RootRouter(ordersService: ordersService),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter({required this.ordersService});

  final OrdersService ordersService;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.unknown:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        return OrdersListScreen(ordersService: ordersService);
    }
  }
}
