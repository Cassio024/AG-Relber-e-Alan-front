// lib/screens/add_edit_event_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class AddEditEventScreen extends StatefulWidget {
  final String userId;
  final Event? event;
  final DateTime? initialDate;

  const AddEditEventScreen({Key? key, required this.userId, this.event, this.initialDate}) : super(key: key);

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

// Simple currency input formatter for pt_BR (thousands '.' and decimal ',')
class CurrencyTextInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // keep only digits
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) digits = '0';
    double value = double.parse(digits) / 100;
    final newText = _formatter.format(value).trim();
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController;
  late TextEditingController _venueController;
  late TextEditingController _valueController;
  late TextEditingController _descriptionController;
  late TextEditingController _timeController;
  DateTime? _selectedDate;
  String _selectedStatus = 'reserva';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.event != null;
    _eventNameController = TextEditingController(text: isEditing ? widget.event!.eventName : '');
    _venueController = TextEditingController(text: isEditing ? widget.event!.venue : '');
  // Format value using Brazilian currency style (thousands '.' and decimal ',')
  final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: 2);
  _valueController = TextEditingController(text: isEditing ? currencyFormatter.format(widget.event!.value) : '');
    _descriptionController = TextEditingController(text: isEditing ? widget.event!.description : '');
    if (isEditing) {
      _selectedDate = widget.event!.dateTime;
    } else if (widget.initialDate != null) {
      // Preserve only the date portion of initialDate, keep current time if not provided
      _selectedDate = DateTime(widget.initialDate!.year, widget.initialDate!.month, widget.initialDate!.day, widget.initialDate!.hour, widget.initialDate!.minute);
    } else {
      _selectedDate = DateTime.now();
    }
  _selectedStatus = isEditing ? widget.event!.status : 'reserva';
    _timeController = TextEditingController(
      text: isEditing
          ? '${widget.event!.dateTime.hour.toString().padLeft(2, '0')}:${widget.event!.dateTime.minute.toString().padLeft(2, '0')}'
          : (widget.initialDate != null
              ? '${widget.initialDate!.hour.toString().padLeft(2, '0')}:${widget.initialDate!.minute.toString().padLeft(2, '0')}'
              : '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}'),
    );
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _venueController.dispose();
    _valueController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  // FUNÇÃO ATUALIZADA: Não pede mais a hora
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        // Guarda a data preservando a hora atual (se houver)
        final hm = _parseHourMinute(_timeController.text);
        _selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, hm[0], hm[1]);
      });
    }
  }

  // Retorna [hora, minuto] a partir de uma string "HH:mm". Se inválido, retorna [0,0].
  List<int> _parseHourMinute(String text) {
    try {
      final parts = text.split(':');
      if (parts.length == 2) {
        final h = int.tryParse(parts[0].trim()) ?? 0;
        final m = int.tryParse(parts[1].trim()) ?? 0;
        if (h >= 0 && h < 24 && m >= 0 && m < 60) return [h, m];
      }
    } catch (_) {}
    return [0, 0];
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final hm = _parseHourMinute(_timeController.text);
        final finalDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          hm[0],
          hm[1],
        );
        // parse value from formatted input (e.g. "40.000,00") to double
        double parsedValue = _parseCurrencyToDouble(_valueController.text);
        if (widget.event == null) {
          await ApiService.createEvent(
            widget.userId,
            _eventNameController.text,
            _venueController.text,
            finalDateTime,
            parsedValue,
            _selectedStatus,
            _descriptionController.text,
          );
        } else {
          await ApiService.updateEvent(widget.event!.id, {
            'eventName': _eventNameController.text,
            'venue': _venueController.text,
            'dateTime': finalDateTime.toIso8601String(),
            'value': parsedValue,
            'status': _selectedStatus,
            'description': _descriptionController.text,
          });
        }
        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  double _parseCurrencyToDouble(String text) {
    if (text.trim().isEmpty) return 0.0;
    // remove thousands separator and keep decimal comma
    final cleaned = text.replaceAll('.', '').replaceAll(RegExp(r'[^0-9,]'), '');
    final normalized = cleaned.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? 'Adicionar Evento' : 'Editar Evento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _eventNameController, decoration: const InputDecoration(labelText: 'Nome do Evento'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _venueController, decoration: const InputDecoration(labelText: 'Cidade'), validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: 'R\$ '),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyTextInputFormatter(),
                ],
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['reserva', 'Aguardando contrato', 'confirmado'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                onChanged: (newValue) => setState(() => _selectedStatus = newValue!),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Data do Evento'),
                  child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Hora (HH:mm)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final parts = _parseHourMinute(_timeController.text);
                      final initial = TimeOfDay(hour: parts[0], minute: parts[1]);
                      final picked = await showTimePicker(context: context, initialTime: initial);
                      if (picked != null) {
                        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                        // update selected date's time as well
                        if (_selectedDate != null) {
                          setState(() {
                            _selectedDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, picked.hour, picked.minute);
                          });
                        }
                      }
                    },
                  ),
                ),
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                  LengthLimitingTextInputFormatter(5),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                  final parts = v.split(':');
                  if (parts.length != 2) return 'Formato inválido (HH:mm)';
                  final h = int.tryParse(parts[0].trim());
                  final m = int.tryParse(parts[1].trim());
                  if (h == null || m == null) return 'Formato inválido (HH:mm)';
                  if (h < 0 || h > 23 || m < 0 || m > 59) return 'Hora inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Descrição / Itens'), maxLines: 4),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _isLoading ? null : _saveEvent, child: Text(widget.event == null ? 'Salvar Evento' : 'Atualizar Evento')),
            ],
          ),
        ),
      ),
    );
  }
}
