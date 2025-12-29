import 'package:eventba_mobile/widgets/master_screen.dart';
import 'package:eventba_mobile/widgets/primary_button.dart';
import 'package:eventba_mobile/providers/user_question_provider.dart';
import 'package:eventba_mobile/models/user_question/user_question.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventQuestionsScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EventQuestionsScreen({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  @override
  State<EventQuestionsScreen> createState() => _EventQuestionsScreenState();
}

class _EventQuestionsScreenState extends State<EventQuestionsScreen> {
  List<UserQuestion> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questionProvider = Provider.of<UserQuestionProvider>(
        context,
        listen: false,
      );

      final questions = await questionProvider.getQuestionsForEvent(
        widget.eventId,
      );
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showReplyDialog(UserQuestion question) async {
    final TextEditingController replyController = TextEditingController(
      text: question.answer ?? '',
    );
    final size = MediaQuery.of(context).size;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Reply to question",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Question: ${question.question}",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: replyController,
                  autofocus: true,
                  maxLines: 3,
                  enabled: question.answer == null || question.answer!.isEmpty,
                  decoration: const InputDecoration(
                    hintText: "Enter your reply here",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
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
                  if (question.answer == null || question.answer!.isEmpty)
                    PrimaryButton(
                      text: "Send",
                      width: size.width * 0.3,
                      small: true,
                      onPressed: () async {
                        if (replyController.text.trim().isNotEmpty) {
                          try {
                            final questionProvider =
                                Provider.of<UserQuestionProvider>(
                                  context,
                                  listen: false,
                                );
                            await questionProvider.update(question.id, {
                              'id': question.id,
                              'answer': replyController.text.trim(),
                              'isAnswered': true,
                              'answeredAt': DateTime.now().toIso8601String(),
                            });
                            Navigator.pop(context);
                            await _loadQuestions();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    "Answer submitted successfully!",
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text("Failed to submit answer: $e"),
                                ),
                              );
                            }
                          }
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

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
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
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text("No questions yet."),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                final hasAnswer =
                    question.answer != null && question.answer!.isNotEmpty;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      question.question,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Asked by: ${question.userName}"),
                        Text(
                          "Date: ${_formatDate(question.createdAt)}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (hasAnswer) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Your Answer:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  question.answer!,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                if (question.answeredAt != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "Answered on: ${_formatDate(question.answeredAt!)}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    leading: const Icon(
                      Icons.question_answer,
                      color: Colors.blue,
                    ),
                    trailing: !hasAnswer
                        ? TextButton(
                            onPressed: () => _showReplyDialog(question),
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
