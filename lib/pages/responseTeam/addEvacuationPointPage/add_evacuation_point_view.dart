import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/pages/responseTeam/addEvacuationPointPage/add_evacuation_point_view_model.dart';
import 'package:resqapp/pages/responseTeam/addEvacuationPointPage/sections/add_evac_point_form_section.dart';
import 'package:resqapp/theme/theme_app.dart';

class AddEvacuationPointView extends GetView<AddEvacuationPointViewModel> {
  final String? instanceCode;
  final EvacuationPoint? existingEvacuationPoint; // For editing mode

  const AddEvacuationPointView({
    super.key,
    this.instanceCode,
    this.existingEvacuationPoint,
  });

  @override
  Widget build(BuildContext context) {
    const theme = ResQTheme();

    if (!Get.isRegistered<AddEvacuationPointViewModel>()) {
      Get.put(
        AddEvacuationPointViewModel(
          instanceCode: instanceCode ?? 'Unit305',
          existingEvacuationPoint: existingEvacuationPoint,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.25),
        leading: GestureDetector(
          onTap: controller.onBackPressed,
          child: Container(
            width: 30,
            height: 30,
            margin: EdgeInsets.all(12),
            child: Icon(
              Icons.arrow_back_ios,
              color: theme.colors.primary,
              size: 20,
            ),
          ),
        ),
        title: Text(
          existingEvacuationPoint != null
              ? 'Edit Poin Evakuasi'
              : 'Registrasi Poin Evakuasi',
          style: TextStyle(
            fontFamily: 'SF Pro',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: theme.colors.primary,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(children: [AddEvacPointFormSection()]),
    );
  }
}
