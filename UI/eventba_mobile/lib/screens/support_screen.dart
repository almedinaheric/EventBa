import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController questionController = TextEditingController();
  String selectedCategory = "General";
  final List<String> categories = ["General", "Technical", "Billing", "Events"];

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      appBarType: AppBarType.iconsSideTitleCenter,
      title: "Support",
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ask a Question",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF363B3E),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Your question...",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: "Ask",
              onPressed: () {
                // Submit question logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Question submitted successfully!")),
                );
                Navigator.pop(context);
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
