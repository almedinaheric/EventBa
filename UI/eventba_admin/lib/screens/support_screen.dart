import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_question_provider.dart';
import '../widgets/master_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  List<dynamic> _userQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserQuestions();
  }

  Future<void> _loadUserQuestions() async {
    try {
      final provider = Provider.of<UserQuestionProvider>(
        context,
        listen: false,
      );
      final result = await provider.get();

      setState(() {
        _userQuestions = result.result;
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to load user questions: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Support - User Questions',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userQuestions.isEmpty
          ? const Center(
              child: Text(
                'No user questions found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _userQuestions.length,
              itemBuilder: (context, index) {
                final question = _userQuestions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                question['question'] ?? 'No question',
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
                                color: question['isAnswered'] == true
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                question['isAnswered'] == true
                                    ? 'Answered'
                                    : 'Pending',
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
                          'From: ${question['userName'] ?? 'Unknown User'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        if (question['answer'] != null) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Answer:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            question['answer'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${_formatDate(question['createdAt'])}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
