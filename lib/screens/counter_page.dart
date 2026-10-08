// I Gede Pradhana Subawa Deningrat
// 2415051030
import 'package:flutter/material.dart';

import '../constants/student_info.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final ValueNotifier<int> demoCounter = ValueNotifier<int>(0);

  @override
  void dispose() {
    demoCounter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo ValueNotifier'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                studentName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'NIM: 2415051030',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Icon(
                Icons.science_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tahap 4 — nilai ini berubah tanpa setState()',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: () {
                      demoCounter.value--;
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 24),
                  ValueListenableBuilder<int>(
                    valueListenable: demoCounter,
                    builder: (context, value, child) {
                      return Container(
                        constraints: const BoxConstraints(
                          minWidth: 64,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 24),
                  IconButton.filledTonal(
                    onPressed: () {
                      demoCounter.value++;
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}