import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'response_team_sos_report_view_model.dart';
import 'components/title_section.dart';
import 'components/sos_report_card.dart';

class ResponseTeamSOSReportView extends StatelessWidget {
  const ResponseTeamSOSReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ResponseTeamSOSReportViewModel(),
      child: Consumer<ResponseTeamSOSReportViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Title Section
              const TitleSection(),
              // SOS Reports List
              Expanded(
                child: viewModel.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : viewModel.errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  viewModel.errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => viewModel.refreshReports(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : viewModel.sosReports.isEmpty
                            ? const Center(
                                child: Text('No SOS reports available'),
                              )
                            : RefreshIndicator(
                                onRefresh: () => viewModel.refreshReports(),
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  itemCount: viewModel.sosReports.length,
                                  itemBuilder: (context, index) {
                                    final report = viewModel.sosReports[index];
                                    return SOSReportCard(
                                      report: report,
                                      formatTimestamp: viewModel.formatTimestamp,
                                      onViewMapPressed: () {
                                        viewModel.viewOnMap(report.reportId);
                                      },
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }
}