import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/providers/user_question_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController questionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  Future<void> _submitQuestion() async {
    if (questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Please enter your question"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final questionProvider = Provider.of<UserQuestionProvider>(
        context,
        listen: false,
      );

      await questionProvider.insert({
        'question': questionController.text.trim(),
        'isQuestionForAdmin': true,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Question submitted successfully!"),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Failed to submit question: ${e.toString()}"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
              text: _isLoading ? "Submitting..." : "Ask",
              onPressed: _isLoading ? () {} : _submitQuestion,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
