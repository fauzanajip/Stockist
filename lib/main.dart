import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dependency_injection.dart';
import 'core/constants/app_theme.dart';
import 'presentation/routers/app_router.dart';
import 'presentation/blocs/event_bloc/event_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initDependencies();
  
  runApp(const StockistApp());
}

class StockistApp extends StatelessWidget {
  const StockistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: sl<EventBloc>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<EventBloc>(
            create: (context) => sl<EventBloc>()..add(LoadAllEvents()),
          ),
        ],
        child: MaterialApp.router(
          title: 'Stockist App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: AppRouter.router,
        ),
