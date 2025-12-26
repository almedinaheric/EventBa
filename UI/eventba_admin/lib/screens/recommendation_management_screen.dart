import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/providers/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecommendationManagementScreen extends StatefulWidget {
  const RecommendationManagementScreen({super.key});

  @override
  State<RecommendationManagementScreen> createState() =>
      _RecommendationManagementScreenState();
}

class _RecommendationManagementScreenState
    extends State<RecommendationManagementScreen> {
  bool _isTraining = false;
  bool _isRetraining = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Recommendation Management',
      showBackButton: true,
      body: Align(
        alignment: Alignment.topLeft,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(
              MediaQuery.of(context).size.width < 600 ? 16 : 24,
            ),
            child: _buildActionsSection(),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Management Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage the recommendation model and stored recommendations',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          title: 'Train Model',
          description:
              'Train the recommendation model using current data. This will analyze user favorites, ticket purchases, and category preferences.',
          icon: Icons.train_outlined,
          color: Colors.green,
          isLoading: _isTraining,
          onTap: _trainModel,
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          title: 'Retrain Model',
          description:
              'Reset and retrain the recommendation model from scratch. Use this when you want to refresh recommendations with new data.',
          icon: Icons.refresh_outlined,
          color: Colors.blue,
          isLoading: _isRetraining,
          onTap: _retrainModel,
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          title: 'Delete All Recommendations',
          description:
              'Remove all stored recommendations from the database. The model will generate new recommendations on the next user request.',
          icon: Icons.delete_outline,
          color: Colors.red,
          isLoading: _isDeleting,
          onTap: _deleteRecommendations,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDestructive
              ? Colors.red.withOpacity(0.3)
              : color.withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width < 600 ? 16 : 20,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 500;
              if (isSmallScreen) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDestructive ? Colors.red : Colors.black,
                            ),
                          ),
                        ),
                        if (isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.3,
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDestructive ? Colors.red : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _trainModel() async {
    setState(() {
      _isTraining = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.trainRecommendationModel();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recommendation model trained successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to train model: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTraining = false;
        });
      }
    }
  }

  Future<void> _retrainModel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Retrain Model'),
          content: const Text(
            'This will reset the current model and train it from scratch. This may take a few moments. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Retrain'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isRetraining = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.retrainRecommendationModel();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recommendation model retrained successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to retrain model: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRetraining = false;
        });
      }
    }
  }

  Future<void> _deleteRecommendations() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Recommendations'),
          content: const Text(
            'This will permanently delete all stored recommendations from the database. New recommendations will be generated when users request them. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      await eventProvider.deleteAllRecommendations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All recommendations deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete recommendations: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}
