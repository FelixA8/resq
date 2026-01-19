import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/pages/responseTeam/responseTeamSOSReport/components/sos_centered_info_text.dart';
import 'sos_page_view_model.dart';
import 'components/title_section.dart';
import 'components/sos_report_card.dart';

class ResponseTeamSOSListView extends StatelessWidget {
  const ResponseTeamSOSListView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.put(ResponseTeamSOSListViewModel());

    return Column(
      children: [
        const SOSListTitleSection(),
        Expanded(
          child: Obx(() {
            if (viewModel.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage.value != null) {
              return SosCenteredInfoText(
                text:
                    viewModel.errorMessage.value ??
                    "Terjadi error, silahkan coba beberapa saat lagi.",
              );
            }

            if (viewModel.sosReports.isEmpty) {
              return RefreshIndicator(
                child: SosCenteredInfoText(
                  text: 'Belum ada laporan SOS saat ini.',
                ),
                onRefresh: () async {
                  viewModel.refreshReports();
                },
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
