import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dependency_injection.dart';
import 'core/constants/app_theme.dart';
import 'presentation/routers/app_router.dart';
import 'presentation/blocs/event_bloc/event_bloc.dart';
import 'presentation/blocs/event_bloc/event_event.dart';
import 'presentation/blocs/product_bloc/product_bloc.dart';
import 'presentation/blocs/product_bloc/product_event.dart';
import 'presentation/blocs/spg_bloc/spg_bloc.dart';
import 'presentation/blocs/spg_bloc/spg_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initDependencies();
  
  runApp(const StockistApp());
}

class StockistApp extends StatelessWidget {
  const StockistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EventBloc>(
          create: (context) => sl<EventBloc>()..add(LoadAllEvents()),
        ),
        BlocProvider<ProductBloc>(
          create: (context) => sl<ProductBloc>()..add(LoadActiveProducts()),
        ),
        BlocProvider<SpgBloc>(
          create: (context) => sl<SpgBloc>()..add(LoadActiveSpqs()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Stockist App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('id', 'ID'),
        ],
      ),
    );
  }
}
