import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportDisasterViewModel extends ChangeNotifier {
  String? selectedDisasterType;
  String? description;
  XFile? pickedImage;

  void setDisasterType(String? type) {
    selectedDisasterType = type;
    notifyListeners();
  }

  void setDescription(String? desc) {
    description = desc;
    notifyListeners();
  }

  void setPickedImage(XFile? image) {
    pickedImage = image;
    notifyListeners();
  }

  // Add more business logic as needed
}
