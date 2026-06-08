// lib/screens/event_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import 'add_edit_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final String userId;

  const EventDetailScreen({Key? key, required this.event, required this.userId}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Event _currentEvent;

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentEvent.eventName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => AddEditEventScreen(userId: widget.userId, event: _currentEvent),
                ),
              );
              if (result == true) Navigator.of(context).pop(true);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cidade: ${_currentEvent.venue}'),
            Text('Data: ${DateFormat("dd/MM/yyyy HH:mm").format(_currentEvent.dateTime)}'),
            Text('Valor: ${NumberFormat.currency(locale: "pt_BR", symbol: "").format(_currentEvent.value)} reais'),
            Text('Status: ${_currentEvent.status}'),
            const Divider(),
            Text('Descrição:', style: Theme.of(context).textTheme.titleLarge),
            Text(_currentEvent.description),
          ],
        ),
      ),
    );
  }
}
