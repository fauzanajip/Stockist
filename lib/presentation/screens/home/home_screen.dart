import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart' as app_formatters;
import '../../../domain/entities/event_entity.dart';
import '../../blocs/event_bloc/event_bloc.dart';
import '../../blocs/event_bloc/event_event.dart';
import '../../blocs/event_bloc/event_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure data is fresh when entering Home
    context.read<EventBloc>().add(LoadAllEvents());
  }

  Future<void> _onRefresh() async {
    context.read<EventBloc>().add(LoadAllEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stockist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.pushNamed('settings'),
          ),
          IconButton(
            icon: const Icon(Icons.backup),
            onPressed: () => context.pushNamed('backup'),
          ),
        ],
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading || state is EventInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EventsLoaded) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child:
                  state.events.isEmpty
                      ? _buildEmptyState(context)
                      : _buildEventList(context, state.events),
            );
          }
          if (state is EventError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<EventBloc>().add(LoadAllEvents()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('create_event'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.event_note,
                size: 64,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada event',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Klik + untuk membuat event baru',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventList(BuildContext context, List<EventEntity> events) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  event.status == 'OPEN'
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
              child: Icon(
                event.status == 'OPEN' ? Icons.event : Icons.event_busy,
                color: Colors.white,
              ),
            ),
            title: Text(
              event.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              '${app_formatters.Formatters.formatDate(event.date)} - ${event.status}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap:
                () => context.pushNamed(
                  'event_detail',
                  pathParameters: {'eventId': event.id},
                ),
          ),
        );
      },
    );
  }
}
