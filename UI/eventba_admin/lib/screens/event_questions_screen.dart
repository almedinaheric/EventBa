import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class EventQuestionsScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventQuestionsScreen({super.key, required this.eventData});

  @override
  State<EventQuestionsScreen> createState() => _EventQuestionsScreenState();
}

class _EventQuestionsScreenState extends State<EventQuestionsScreen> {
  // Copy questions to a mutable list so replies can be added
  late List<Map<String, dynamic>> questions;

  @override
  void initState() {
    super.initState();
    // Initialize questions, add a "reply" field to each question (empty initially)
    questions = (widget.eventData['questions'] as List<dynamic>? ?? [
      {"question": "Is parking available?", "askedBy": "user123", "reply": null},
      {"question": "Will there be food stalls?", "askedBy": "foodie567", "reply": null},
    ]).map((q) {
      return {
        "question": q['question'],
        "askedBy": q['askedBy'],
        "reply": q['reply'],
      };
    }).toList();
  }

  Future<void> _showReplyDialog(int questionIndex) async {
    final TextEditingController replyController = TextEditingController();
    final size = MediaQuery.of(context).size;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reply to question", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          content: SizedBox(
            width: size.width * 0.9, // 90% of screen width
            child: TextField(
              controller: replyController,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Enter your reply here",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,  // wrap content tightly
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
                  const SizedBox(width: 12), // space between buttons
                  PrimaryButton(
                    text: "Send",
                    width: size.width * 0.3,
                    small: true,
                    onPressed: () {
                      if (replyController.text.trim().isNotEmpty) {
                        setState(() {
                          questions[questionIndex]['reply'] = replyController.text.trim();
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Event Questions",
      initialIndex: 4,
      appBarType: AppBarType.iconsSideTitleCenter,
      leftIcon: Icons.arrow_back,
      onLeftButtonPressed: () {
        Navigator.pop(context);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final reply = question['reply'] as String?;
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(
                question["question"] ?? "",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Asked by: ${question["askedBy"] ?? "anonymous"}"),
                  if (reply != null && reply.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Reply: $reply",
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              leading: const Icon(Icons.question_answer, color: Colors.blue),
              trailing: (reply == null || reply.isEmpty)
                  ? TextButton(
                onPressed: () => _showReplyDialog(index),
                child: const Text("Reply"),
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
