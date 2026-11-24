import 'package:flutter/material.dart';

import '../service/order_service.dart';

class OrderHelpScreen extends StatefulWidget {
  const OrderHelpScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderHelpScreen> createState() => _OrderHelpScreenState();
}

class _OrderHelpScreenState extends State<OrderHelpScreen> {
  final _message = TextEditingController();
  bool _sending = false;
  bool _failed = false;
  int? _reference;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final message = _message.text.trim();
    if (_sending || message.isEmpty) return;
    setState(() {
      _sending = true;
      _failed = false;
    });
    int? reference;
    try {
      reference = await OrderService.requestHelp(widget.orderId, message);
    } catch (_) {
      // Keep the draft available for another attempt.
    }
    if (!mounted) return;
    setState(() {
      _sending = false;
      _reference = reference;
      _failed = reference == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help with order #${widget.orderId}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_reference case final reference?)
            Text('Request sent. Your support reference is #$reference.')
          else ...[
            TextField(
              controller: _message,
              enabled: !_sending,
              onChanged: (_) => setState(() {}),
              maxLength: 2000,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'How can we help?',
                border: OutlineInputBorder(),
              ),
            ),
            if (_failed) const Text('Could not send your request. Try again.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed:
                  _sending || _message.text.trim().isEmpty ? null : _send,
              child: Text(_sending ? 'Sending…' : 'Send request'),
            ),
          ],
        ],
      ),
    );
  }
}
