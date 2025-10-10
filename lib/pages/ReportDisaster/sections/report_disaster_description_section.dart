import 'package:flutter/material.dart';
import '../ReportDisasterViewModel.dart';
import 'package:provider/provider.dart';

class ReportDisasterDescriptionSection extends StatelessWidget {
  const ReportDisasterDescriptionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ReportDisasterViewModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keterangan',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          minLines: 2,
          maxLines: 4,
          onChanged: viewModel.setDescription,
          decoration: InputDecoration(
            hintText: 'Deskripsikan bencana yang anda lihat!',
            hintStyle: const TextStyle(
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Color(0xFF9E9E9E),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F8F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
