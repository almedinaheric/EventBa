import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this dependency to pubspec.yaml

class ReportGenerationScreen extends StatefulWidget {
  const ReportGenerationScreen({super.key});

  @override
  State<ReportGenerationScreen> createState() => _ReportGenerationScreenState();
}

class _ReportGenerationScreenState extends State<ReportGenerationScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  bool isGenerating = false;

  final List<Map<String, dynamic>> reportOptions = [
    {
      'title': 'Events Overview',
      'description': 'Number of private events, public events, and total attendees',
      'icon': Icons.event_available,
      'color': const Color(0xFF4776E6),
    },
    {
      'title': 'Category Analysis',
      'description': 'Number of events by categories and hottest category',
      'icon': Icons.category,
      'color': Colors.orange,
    },
    {
      'title': 'Attendance Report',
      'description': 'Events with most/least attendees and attendance statistics',
      'icon': Icons.people,
      'color': Colors.green,
    },
    {
      'title': 'User Activity',
      'description': 'User with most events and user engagement metrics',
      'icon': Icons.person_outline,
      'color': Colors.purple,
    },
    {
      'title': 'Complete Report',
      'description': 'Comprehensive report with all metrics and analytics',
      'icon': Icons.assessment,
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Generate Report',
      showBackButton: true,
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection Section
            _buildDateSelectionSection(),

            const SizedBox(height: 32),

            // Report Options Section
            _buildReportOptionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4776E6), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date Range',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose the date range for your report generation',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  label: 'From Date',
                  date: fromDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateSelector(
                  label: 'To Date',
                  date: toDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: date != null ? const Color(0xFF4776E6) : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('MMM dd, yyyy').format(date!)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null ? Colors.black : Colors.grey,
                      fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOptionsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report Types',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select the type of report you want to generate',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: reportOptions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = reportOptions[index];
                return _buildReportOptionCard(option);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOptionCard(Map<String, dynamic> option) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _generateReport(option['title']),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: option['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  option['icon'],
                  color: option['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option['description'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (isGenerating)
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
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4776E6),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
          // Clear toDate if it's before fromDate
          if (toDate != null && toDate!.isBefore(picked)) {
            toDate = null;
          }
        } else {
          // Only allow toDate if fromDate is selected and toDate is after fromDate
          if (fromDate != null && picked.isAfter(fromDate!)) {
            toDate = picked;
          } else if (fromDate == null) {
            _showErrorDialog('Please select a "From Date" first');
          } else {
            _showErrorDialog('To Date must be after From Date');
          }
        }
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Date Selection'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateReport(String reportType) async {
    if (fromDate == null || toDate == null) {
      _showErrorDialog('Please select both From Date and To Date');
      return;
    }

    setState(() {
      isGenerating = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Call your backend API here
      await _callBackendForReport(reportType);

      // Show success dialog
      _showSuccessDialog(reportType);
    } catch (e) {
      _showErrorDialog('Failed to generate report. Please try again.');
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }

  Future<void> _callBackendForReport(String reportType) async {
    // Replace this with your actual backend API call
    final Map<String, dynamic> requestData = {
      'reportType': reportType,
      'fromDate': DateFormat('yyyy-MM-dd').format(fromDate!),
      'toDate': DateFormat('yyyy-MM-dd').format(toDate!),
      'metrics': _getMetricsForReportType(reportType),
    };

    print('Calling backend with data: $requestData');

    // Example API call structure:
    // final response = await http.post(
    //   Uri.parse('${ApiConstants.baseUrl}/reports/generate'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(requestData),
    // );

    // Handle the response and trigger PDF download
    // The backend should return a PDF file or a download URL
  }

  List<String> _getMetricsForReportType(String reportType) {
    switch (reportType) {
      case 'Events Overview':
        return [
          'number_of_private_events',
          'number_of_public_events',
          'total_attendees_private',
          'total_attendees_public',
        ];
      case 'Category Analysis':
        return [
          'events_by_category',
          'hottest_category',
          'category_attendance',
        ];
      case 'Attendance Report':
        return [
          'event_with_most_attendees',
          'event_with_least_attendees',
          'average_attendance',
          'attendance_trends',
        ];
      case 'User Activity':
        return [
          'user_with_most_events',
          'user_engagement_metrics',
          'active_users_count',
        ];
      case 'Complete Report':
        return [
          'number_of_private_events',
          'number_of_public_events',
          'total_attendees_private',
          'total_attendees_public',
          'events_by_category',
          'hottest_category',
          'event_with_most_attendees',
          'event_with_least_attendees',
          'user_with_most_events',
          'user_engagement_metrics',
        ];
      default:
        return [];
    }
  }

  void _showSuccessDialog(String reportType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Generated Successfully'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$reportType has been generated successfully.'),
              const SizedBox(height: 8),
              Text(
                'Date Range: ${DateFormat('MMM dd, yyyy').format(fromDate!)} - ${DateFormat('MMM dd, yyyy').format(toDate!)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'The PDF report will be downloaded automatically.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}