import 'package:flutter/material.dart';
import '../../models/task_detail_model.dart';
import '../../../../core/utils/date_formatter.dart';

class StatusTimeline extends StatelessWidget {
  final List<StatusTransition> history;

  const StatusTimeline({super.key, required this.history});

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Text('No history available.', style: TextStyle(color: Colors.grey));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final transition = history[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 12, color: Colors.blue),
                  if (index != history.length - 1)
                    Container(width: 2, height: 50, color: Colors.grey.shade300),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Changed to ${transition.newStatus}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${transition.createdBy.name} at ${DateFormatter.format(transition.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (transition.note != null && transition.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (transition.imageUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 6.0, top: 2.0),
                              child: GestureDetector(
                                onTap: () {
                                  _showImageDialog(context, transition.imageUrl!);
                                },
                                child: const Icon(Icons.image, size: 16, color: Colors.blue),
                              ),
                            ),
                          Expanded(
                            child: Text('"${transition.note}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                          ),
                        ],
                      ),
                    ] else if (transition.imageUrl != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showImageDialog(context, transition.imageUrl!);
                            },
                            child: const Icon(Icons.image, size: 16, color: Colors.blue),
                          ),
                          const SizedBox(width: 6),
                          const Text('Imagen adjunta', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
