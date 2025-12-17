import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/theme/theme_app.dart';
import 'response_team_sos_report_view_model.dart';
import 'components/title_section.dart';
import 'components/sos_report_card.dart';

class ResponseTeamSOSReportView extends StatelessWidget {
  const ResponseTeamSOSReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.put(ResponseTeamSOSReportViewModel());
    final theme = ResQTheme();

    return Column(
      children: [
        const TitleSection(),
        Expanded(
          child: Obx(() {
            if (viewModel.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage.value != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      viewModel.errorMessage.value!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: theme.font.semibold,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Coba lagi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: theme.font.semibold,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.sosReports.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ditemukan SOS, Silahkan coba lagi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: theme.font.semibold,
                        fontFamily: 'SF Pro',
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => viewModel.refreshReports(),
              child: ListView.builder(
                controller: viewModel.scrollController,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount:
                    viewModel.sosReports.length +
                    (viewModel.hasMoreData.value ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show loading indicator at the bottom
                  if (index == viewModel.sosReports.length) {
                    return viewModel.isLoadingMore.value
                        ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }

                  final reportItem = viewModel.sosReports[index];
                  return SOSReportCard(
                    reportItem: reportItem,
                    formatTimestamp: viewModel.formatTimestamp,
                    onViewMapPressed: () {
                      viewModel.viewOnMap(reportItem.sosEvent.sosId);
                    },
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
