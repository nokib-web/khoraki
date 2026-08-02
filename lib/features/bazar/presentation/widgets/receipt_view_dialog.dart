import 'package:flutter/material.dart';

class ReceiptViewDialog extends StatelessWidget {
  final String imageUrl;

  const ReceiptViewDialog({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withAlpha(220),
      insetPadding: const EdgeInsets.all(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text(
                    'Failed to load receipt image',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
