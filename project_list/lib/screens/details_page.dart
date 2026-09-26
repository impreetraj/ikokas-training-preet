import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> projectData;

  const DetailsPage({super.key, required this.projectData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(projectData['title'] ?? 'Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              projectData['description'] ?? 'No description available.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            
            if (projectData['tech_stack'] != null) ...[
              const Text(
                'Tech Stack',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: (projectData['tech_stack'] as List<dynamic>).map((tech) {
                  return Chip(label: Text(tech.toString()));
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            const Text(
              'Features',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            if (projectData.containsKey('features'))
              ..._buildFeaturesList(projectData['features'])
            else if (projectData.containsKey('frontend_features') || projectData.containsKey('backend_features'))
              ...[
                if (projectData.containsKey('frontend_features')) ...[
                  const Text('Frontend Features', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 4),
                  ..._buildFeaturesList(projectData['frontend_features']),
                  const SizedBox(height: 8),
                ],
                if (projectData.containsKey('backend_features')) ...[
                  const Text('Backend Features', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 4),
                  ..._buildFeaturesList(projectData['backend_features']),
                ],
              ]
            else if (projectData.containsKey('layers'))
              ..._buildFeaturesList(projectData['layers'])
            else
              const Text('No detailed features available.'),
          ],
        ),
      ),
      ),
    );
  }

  List<Widget> _buildFeaturesList(Map<String, dynamic> featuresMap) {
    return featuresMap.entries.map((entry) {
      final value = entry.value;
      if (value is String) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text('• ${entry.key}:\n  $value'),
        );
      } else if (value is List) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ${entry.key}:', style: const TextStyle(fontWeight: FontWeight.bold)),
              ...value.map((v) => Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                    child: Text('- $v'),
                  )),
            ],
          ),
        );
      } else if (value is Map) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ${entry.key}:', style: const TextStyle(fontWeight: FontWeight.bold)),
              ...value.entries.map((nested) => Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                    child: Text('- ${nested.key}: ${nested.value}'),
                  )),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }
}
