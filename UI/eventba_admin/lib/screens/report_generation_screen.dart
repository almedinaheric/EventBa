import 'dart:io';
import 'package:eventba_admin/widgets/master_screen.dart';
import 'package:eventba_admin/providers/event_provider.dart';
import 'package:eventba_admin/providers/category_provider.dart';
import 'package:eventba_admin/providers/user_provider.dart';
import 'package:eventba_admin/models/event/event.dart';
import 'package:eventba_admin/models/category/category_model.dart';
import 'package:eventba_admin/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';

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
      'description':
          'Number of private events, public events, and total attendees',
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
      'description':
          'Events with most/least attendees and attendance statistics',
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
            style: TextStyle(fontSize: 14, color: Colors.grey),
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
                        ? DateFormat('MMM dd, yyyy').format(date)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null ? Colors.black : Colors.grey,
                      fontWeight: date != null
                          ? FontWeight.w600
                          : FontWeight.normal,
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
            style: TextStyle(fontSize: 14, color: Colors.grey),
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
        onTap: isGenerating ? null : () => _generateReport(option['title']),
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
                child: Icon(option['icon'], color: option['color'], size: 24),
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
            colorScheme: const ColorScheme.light(primary: Color(0xFF4776E6)),
          ),
          child: child ?? const SizedBox.shrink(),
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
          title: const Text('Error'),
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
      // Fetch data based on report type
      final reportData = await _fetchReportData(reportType);

      // Generate PDF
      await _generateAndDownloadPDF(reportType, reportData);
    } catch (e) {
      print("Error generating report: $e");
      _showErrorDialog('Failed to generate report: $e');
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchReportData(String reportType) async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Get all events (we'll filter by date range in the app)
    final allEvents = await eventProvider.get(
      filter: {'page': 1, 'pageSize': 1000},
    );

    // Filter events by date range
    final filteredEvents = allEvents.result.where((event) {
      try {
        final eventDate = DateFormat('yyyy-MM-dd').parse(event.startDate);
        return eventDate.isAfter(fromDate!.subtract(const Duration(days: 1))) &&
            eventDate.isBefore(toDate!.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();

    final categories = await categoryProvider.get(
      filter: {'page': 1, 'pageSize': 1000},
    );

    Map<String, dynamic> data = {
      'events': filteredEvents,
      'categories': categories.result,
      'fromDate': fromDate!,
      'toDate': toDate!,
    };

    // Add specific data based on report type
    switch (reportType) {
      case 'Events Overview':
        data['publicEvents'] = filteredEvents
            .where((e) => e.type.name == 'Public')
            .toList();
        data['privateEvents'] = filteredEvents
            .where((e) => e.type.name == 'Private')
            .toList();
        break;
      case 'Category Analysis':
        // Group events by category
        final eventsByCategory = <String, int>{};
        for (var event in filteredEvents) {
          final categoryName = event.category?.name ?? 'Uncategorized';
          eventsByCategory[categoryName] =
              (eventsByCategory[categoryName] ?? 0) + 1;
        }
        data['eventsByCategory'] = eventsByCategory;
        break;
      case 'Attendance Report':
        // Sort events by attendance
        final sortedByAttendance = List<Event>.from(filteredEvents)
          ..sort((a, b) => b.currentAttendees.compareTo(a.currentAttendees));
        data['sortedEvents'] = sortedByAttendance;
        break;
      case 'User Activity':
        // Get all unique organizer IDs from events
        final organizerIds = filteredEvents
            .map((e) => e.organizerId)
            .toSet()
            .toList();

        // Fetch user details for all organizers (including admins)
        final allUsers = await userProvider.get(
          filter: {'page': 1, 'pageSize': 1000, 'excludeAdmins': false},
        );

        // Also fetch individual users if needed (for organizers not in the list)
        final organizerUsers = <User>[];
        for (var organizerId in organizerIds) {
          try {
            User? foundUser;
            try {
              foundUser = allUsers.result.firstWhere(
                (u) => u.id == organizerId,
              );
            } catch (e) {
              // User not found in list, try to fetch individually
              try {
                foundUser = await userProvider.getUserById(organizerId);
              } catch (fetchError) {
                print("Could not fetch user $organizerId: $fetchError");
              }
            }

            if (foundUser != null) {
              organizerUsers.add(foundUser);
            }
          } catch (e) {
            print("Error processing organizer $organizerId: $e");
          }
        }

        data['users'] = organizerUsers.isNotEmpty
            ? organizerUsers
            : allUsers.result;
        break;
      case 'Complete Report':
        // Prepare all data structures for complete report
        // Events Overview data
        data['publicEvents'] = filteredEvents
            .where((e) => e.type.name == 'Public')
            .toList();
        data['privateEvents'] = filteredEvents
            .where((e) => e.type.name == 'Private')
            .toList();

        // Category Analysis data
        final eventsByCategory = <String, int>{};
        for (var event in filteredEvents) {
          final categoryName = event.category?.name ?? 'Uncategorized';
          eventsByCategory[categoryName] =
              (eventsByCategory[categoryName] ?? 0) + 1;
        }
        data['eventsByCategory'] = eventsByCategory;

        // Attendance Report data
        final sortedByAttendance = List<Event>.from(filteredEvents)
          ..sort((a, b) => b.currentAttendees.compareTo(a.currentAttendees));
        data['sortedEvents'] = sortedByAttendance;

        // User Activity data - fetch all organizers
        final organizerIds = filteredEvents
            .map((e) => e.organizerId)
            .toSet()
            .toList();
        final allUsers = await userProvider.get(
          filter: {'page': 1, 'pageSize': 1000, 'excludeAdmins': false},
        );

        final organizerUsers = <User>[];
        for (var organizerId in organizerIds) {
          try {
            User? foundUser;
            try {
              foundUser = allUsers.result.firstWhere(
                (u) => u.id == organizerId,
              );
            } catch (e) {
              try {
                foundUser = await userProvider.getUserById(organizerId);
              } catch (fetchError) {
                print("Could not fetch user $organizerId: $fetchError");
              }
            }

            if (foundUser != null) {
              organizerUsers.add(foundUser);
            }
          } catch (e) {
            print("Error processing organizer $organizerId: $e");
          }
        }

        data['users'] = organizerUsers.isNotEmpty
            ? organizerUsers
            : allUsers.result;
        break;
    }

    return data;
  }

  Future<void> _generateAndDownloadPDF(
    String reportType,
    Map<String, dynamic> data,
  ) async {
    final pdf = pw.Document();

    // Load logo image
    final ByteData logoData = await rootBundle.load(
      'assets/icons/app_icon.png',
    );
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.ImageProvider logoImage = pw.MemoryImage(logoBytes);

    // Load Poppins font for Unicode support
    final ByteData fontData = await rootBundle.load(
      'assets/fonts/poppins/Poppins-Regular.ttf',
    );
    final pw.Font poppinsRegular = pw.Font.ttf(fontData);

    final ByteData fontBoldData = await rootBundle.load(
      'assets/fonts/poppins/Poppins-Bold.ttf',
    );
    final pw.Font poppinsBold = pw.Font.ttf(fontBoldData);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: poppinsRegular, bold: poppinsBold),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Image(logoImage, width: 50, height: 50),
                    pw.SizedBox(width: 15),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'EventBa',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue,
                          ),
                        ),
                        pw.Text(
                          'Event Management Platform',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      DateFormat('MMM dd, yyyy').format(DateTime.now()),
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'Generated Report',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Report Title
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    reportType,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Date Range: ${DateFormat('MMM dd, yyyy').format(data['fromDate'])} - ${DateFormat('MMM dd, yyyy').format(data['toDate'])}',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 25),

            // Report Content
            ..._buildReportContent(reportType, data),
          ];
        },
      ),
    );

    // Save PDF
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF Report',
      fileName:
          'eventba_${reportType.toLowerCase().replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsBytes(await pdf.save());
    }
  }

  List<pw.Widget> _buildReportContent(
    String reportType,
    Map<String, dynamic> data,
  ) {
    switch (reportType) {
      case 'Events Overview':
        return _buildEventsOverviewContent(data);
      case 'Category Analysis':
        return _buildCategoryAnalysisContent(data);
      case 'Attendance Report':
        return _buildAttendanceReportContent(data);
      case 'User Activity':
        return _buildUserActivityContent(data);
      case 'Complete Report':
        return _buildCompleteReportContent(data);
      default:
        return [pw.Text('Unknown report type')];
    }
  }

  List<pw.Widget> _buildEventsOverviewContent(Map<String, dynamic> data) {
    final publicEvents = (data['publicEvents'] as List<Event>?) ?? <Event>[];
    final privateEvents = (data['privateEvents'] as List<Event>?) ?? <Event>[];
    final allEvents = (data['events'] as List<Event>?) ?? <Event>[];

    final totalPublicAttendees = publicEvents.fold<int>(
      0,
      (sum, e) => sum + e.currentAttendees,
    );
    final totalPrivateAttendees = privateEvents.fold<int>(
      0,
      (sum, e) => sum + e.currentAttendees,
    );

    return [
      _buildSectionTitle('Summary'),
      pw.SizedBox(height: 15),
      _buildStatCard(
        'Total Events',
        allEvents.length.toString(),
        PdfColors.blue,
      ),
      pw.SizedBox(height: 10),
      pw.Row(
        children: [
          pw.Expanded(
            child: _buildStatCard(
              'Public Events',
              publicEvents.length.toString(),
              PdfColors.green,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: _buildStatCard(
              'Private Events',
              privateEvents.length.toString(),
              PdfColors.orange,
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 20),
      _buildSectionTitle('Attendance Statistics'),
      pw.SizedBox(height: 15),
      _buildStatCard(
        'Public Events Attendees',
        totalPublicAttendees.toString(),
        PdfColors.green,
      ),
      pw.SizedBox(height: 10),
      _buildStatCard(
        'Private Events Attendees',
        totalPrivateAttendees.toString(),
        PdfColors.orange,
      ),
      pw.SizedBox(height: 10),
      _buildStatCard(
        'Total Attendees',
        (totalPublicAttendees + totalPrivateAttendees).toString(),
        PdfColors.blue,
      ),
    ];
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue, width: 2),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue900,
        ),
      ),
    );
  }

  pw.Widget _buildStatCard(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color, width: 1.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildCategoryAnalysisContent(Map<String, dynamic> data) {
    final eventsByCategory =
        (data['eventsByCategory'] as Map<String, int>?) ?? <String, int>{};
    final categories =
        (data['categories'] as List<CategoryModel>?) ?? <CategoryModel>[];

    // Build complete category list with event counts (including categories with 0 events)
    final allCategoriesWithCounts = <String, int>{};
    for (var category in categories) {
      final categoryName = category.name;
      allCategoriesWithCounts[categoryName] =
          eventsByCategory[categoryName] ?? 0;
    }

    // Find hottest category
    String? hottestCategory;
    int maxEvents = 0;
    allCategoriesWithCounts.forEach((category, count) {
      if (count > maxEvents) {
        maxEvents = count;
        hottestCategory = category;
      }
    });

    // Sort categories by event count (descending), then by name
    final sortedCategories = allCategoriesWithCounts.entries.toList()
      ..sort((a, b) {
        if (b.value != a.value) {
          return b.value.compareTo(a.value);
        }
        return a.key.compareTo(b.key);
      });

    final tableData = <List<String>>[];
    tableData.add(['Category', 'Number of Events']);
    for (var entry in sortedCategories) {
      tableData.add([entry.key, entry.value.toString()]);
    }

    return [
      _buildSectionTitle('Category Analysis'),
      pw.SizedBox(height: 15),
      _buildStatCard(
        'Total Categories',
        categories.length.toString(),
        PdfColors.purple,
      ),
      pw.SizedBox(height: 20),
      if (hottestCategory != null)
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.orange, width: 2),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Hottest Category',
                      style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      '$hottestCategory ($maxEvents events)',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      pw.SizedBox(height: 20),
      if (tableData.length > 1)
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Table.fromTextArray(
            data: tableData,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(8),
            oddRowDecoration: pw.BoxDecoration(color: PdfColors.grey100),
          ),
        ),
    ];
  }

  List<pw.Widget> _buildAttendanceReportContent(Map<String, dynamic> data) {
    final sortedEvents = (data['sortedEvents'] as List<Event>?) ?? <Event>[];
    if (sortedEvents.isEmpty) {
      return [pw.Text('No events found in the selected date range.')];
    }

    final mostAttended = sortedEvents.first;
    final leastAttended = sortedEvents.last;
    final avgAttendance = sortedEvents.isEmpty
        ? 0
        : (sortedEvents.fold<int>(0, (sum, e) => sum + e.currentAttendees) /
                  sortedEvents.length)
              .round();

    return [
      _buildSectionTitle('Attendance Statistics'),
      pw.SizedBox(height: 15),
      _buildStatCard(
        'Average Attendance',
        avgAttendance.toString(),
        PdfColors.teal,
      ),
      pw.SizedBox(height: 20),
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.green, width: 1.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Most Attended Event',
              style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              mostAttended.title,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green900,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              '${mostAttended.currentAttendees} attendees',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.red, width: 1.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Least Attended Event',
              style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              leastAttended.title,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red900,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              '${leastAttended.currentAttendees} attendees',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    ];
  }

  List<pw.Widget> _buildUserActivityContent(Map<String, dynamic> data) {
    final users = (data['users'] as List?) ?? <dynamic>[];
    final events = (data['events'] as List<Event>?) ?? <Event>[];

    // Count events per user
    final userEventCounts = <String, int>{};
    for (var event in events) {
      userEventCounts[event.organizerId] =
          (userEventCounts[event.organizerId] ?? 0) + 1;
    }

    // Find user with most events
    String? mostActiveUserId;
    int maxEvents = 0;
    userEventCounts.forEach((userId, count) {
      if (count > maxEvents) {
        maxEvents = count;
        mostActiveUserId = userId;
      }
    });

    // Find the user object to get full name
    String? mostActiveUserName;
    if (mostActiveUserId != null) {
      try {
        // Search through users list
        User? foundUser;
        for (var user in users) {
          if (user is User && user.id == mostActiveUserId) {
            foundUser = user;
            break;
          }
        }

        mostActiveUserName = foundUser?.fullName ?? 'Unknown User';

        // Debug print
        if (foundUser == null) {
          print("User not found in list. Looking for ID: $mostActiveUserId");
          print(
            "Available user IDs: ${users.map((u) => u is User ? u.id : 'not User').toList()}",
          );
        } else {
          print("Found user: ${foundUser.fullName} (ID: ${foundUser.id})");
        }
      } catch (e) {
        print("Error finding user: $e");
        mostActiveUserName = 'Unknown User';
      }
    }

    return [
      _buildSectionTitle('User Activity'),
      pw.SizedBox(height: 15),
      pw.Row(
        children: [
          pw.Expanded(
            child: _buildStatCard(
              'Total Users',
              users.length.toString(),
              PdfColors.purple,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: _buildStatCard(
              'Events Created',
              events.length.toString(),
              PdfColors.indigo,
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 20),
      if (mostActiveUserId != null && mostActiveUserName != null)
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.purple, width: 1.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Most Active User',
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                mostActiveUserName,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple900,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                '$maxEvents events created',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
    ];
  }

  List<pw.Widget> _buildCompleteReportContent(Map<String, dynamic> data) {
    return [
      ..._buildEventsOverviewContent(data),
      pw.SizedBox(height: 20),
      pw.Divider(),
      pw.SizedBox(height: 20),
      ..._buildCategoryAnalysisContent(data),
      pw.SizedBox(height: 20),
      pw.Divider(),
      pw.SizedBox(height: 20),
      ..._buildAttendanceReportContent(data),
      pw.SizedBox(height: 20),
      pw.Divider(),
      pw.SizedBox(height: 20),
      ..._buildUserActivityContent(data),
    ];
  }
}
