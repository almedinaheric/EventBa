import 'package:flutter/material.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';

class AddReviewDialog extends StatefulWidget {
  final String eventTitle;
  final Function(int rating, String comment) onSubmit;

  const AddReviewDialog({
    super.key,
    required this.eventTitle,
    required this.onSubmit,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AlertDialog(
      title: const Text(
        "Add Review",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.eventTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Rating",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = index + 1;
                      });
                    },
                    child: Icon(
                      Icons.star,
                      size: 40,
                      color: index < _selectedRating
                          ? Colors.amber
                          : Colors.grey[300],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              const Text(
                "Comment",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                autofocus: false,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Share your experience...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                text: "Cancel",
                width: size.width * 0.3,
                outlined: true,
                small: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 12),
              PrimaryButton(
                text: "Submit",
                width: size.width * 0.3,
                small: true,
                onPressed: () {
                  if (_selectedRating > 0) {
                    widget.onSubmit(
                      _selectedRating,
                      _commentController.text.trim(),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text("Please select a rating"),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
