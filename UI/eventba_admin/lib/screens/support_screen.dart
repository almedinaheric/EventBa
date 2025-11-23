import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_question_provider.dart';
import '../models/user_question/user_question.dart';
import '../widgets/master_screen.dart';
import '../widgets/primary_button.dart';
import 'package:intl/intl.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  List<UserQuestion> _userQuestions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Load questions after the first frame to avoid context issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserQuestions();
    });
  }

  Future<void> _loadUserQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<UserQuestionProvider>(
        context,
        listen: false,
      );
      final questions = await provider.getAdminQuestions();

      setState(() {
        _userQuestions = questions;
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to load user questions: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load questions: ${e.toString()}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _answerQuestion(UserQuestion question) async {
    final TextEditingController answerController = TextEditingController(
      text: question.answer ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Answer Question'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    question.question,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Answer:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: answerController,
                  decoration: const InputDecoration(
                    hintText: 'Type your answer...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 6,
                  minLines: 4,
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (answerController.text.trim().isNotEmpty) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4776E6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Answer'),
            ),
          ],
        );
      },
    );

    if (result == true && answerController.text.trim().isNotEmpty) {
      try {
        final provider = Provider.of<UserQuestionProvider>(
          context,
          listen: false,
        );

        final updateRequest = {
          'id': question.id,
          'answer': answerController.text.trim(),
          'isAnswered': true,
          'answeredAt': DateTime.now().toIso8601String(),
        };

        await provider.updateById(question.id, updateRequest);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Answer submitted successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
          _loadUserQuestions(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit answer: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Support - User Questions',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _userQuestions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserQuestions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _userQuestions.isEmpty
          ? const Center(
              child: Text(
                'No user questions found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserQuestions,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _userQuestions.length,
                itemBuilder: (context, index) {
                  final question = _userQuestions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  question.question,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: question.isAnswered
                                      ? Colors.green
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  question.isAnswered ? 'Answered' : 'Pending',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'From: ${question.userFullName ?? question.userEmail ?? 'Unknown User'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          if (question.answer != null &&
                              question.answer!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Answer:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    question.answer!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  if (question.answeredAt != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Answered on: ${_formatDate(question.answeredAt!)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            'Asked on: ${_formatDate(question.askedAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          if (!question.isAnswered) ...[
                            const SizedBox(height: 12),
                            PrimaryButton(
                              text: 'Answer Question',
                              onPressed: () => _answerQuestion(question),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final dateFormat = DateFormat('MMM dd, yyyy hh:mm a');
      return dateFormat.format(date);
    } catch (e) {
      return dateString;
    }
  }
}
