import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _backendBase = 'https://your-railway-app.up.railway.app';

class ResearchScreen extends StatefulWidget {
  const ResearchScreen({super.key});

  @override
  State<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends State<ResearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String? _result;
  String? _error;

  Future<void> _runQuery() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() { _loading = true; _result = null; _error = null; });

    try {
      final res = await http.post(
        Uri.parse('$_backendBase/research/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() { _result = data['result'] ?? jsonEncode(data); });
      } else {
        setState(() { _error = 'Error ${res.statusCode}: ${res.body}'; });
      }
    } catch (e) {
      setState(() { _error = 'Network error: $e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '🔍 Crypto Research',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'e.g. prediction markets on Solana',
                      hintStyle: TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _runQuery(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _loading ? null : _runQuery,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Suggested queries
            if (_result == null && _error == null && !_loading)
              _SuggestedQueries(onTap: (q) {
                _controller.text = q;
                _runQuery();
              }),

            // Results
            if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _result!,
                      style: const TextStyle(color: Colors.white, height: 1.6),
                    ),
                  ),
                ),
              ),

            // Error
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedQueries extends StatelessWidget {
  final void Function(String) onTap;

  const _SuggestedQueries({required this.onTap});

  static const _suggestions = [
    'Prediction markets on Solana',
    'DeFi lending protocols with AI',
    'Cross-chain wallet UX innovations',
    'Gasless transaction solutions',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Try a query',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions.map((q) => GestureDetector(
            onTap: () => onTap(q),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.4)),
              ),
              child: Text(q, style: const TextStyle(
                color: Colors.deepPurpleAccent, fontSize: 13,
              )),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
