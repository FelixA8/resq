import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../ReportDisasterViewModel.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class ReportDisasterCameraSection extends StatelessWidget {
  const ReportDisasterCameraSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ReportDisasterViewModel>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipe Bencana',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (viewModel.pickedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(viewModel.pickedImage!.path),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              // Camera icon and text always visible, but positioned bottom right if image exists
              if (viewModel.pickedImage == null)
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (pickedFile != null) {
                        viewModel.setPickedImage(pickedFile);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFFB71C1C),
                          size: 36,
                        ),
                        const SizedBox(height: 0),
                        Text(
                          'Buka Kamera',
                          style: const TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: Color(0xFFB71C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (pickedFile != null) {
                        viewModel.setPickedImage(pickedFile);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        'Ambil ulang',
                        style: const TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Color(0xFFB71C1C),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
