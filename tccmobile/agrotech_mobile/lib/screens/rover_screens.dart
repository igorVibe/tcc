import 'package:flutter/material.dart';

class RoversScreen extends StatelessWidget {
  const RoversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rovers'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.agriculture),
              ),
              title: const Text('ROVER-01'),
              subtitle: const Text(
                '🟢 Online\nBateria: 87%',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.agriculture),
              ),
              title: const Text('ROVER-02'),
              subtitle: const Text(
                '🟢 Online\nBateria: 65%',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.agriculture),
              ),
              title: const Text('ROVER-03'),
              subtitle: const Text(
                '🔴 Offline\nBateria: 32%',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        ],
      ),
    );
  }
}