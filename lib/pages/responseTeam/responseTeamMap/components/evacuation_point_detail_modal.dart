import 'package:flutter/material.dart';
import 'package:resqapp/models/supabase_models.dart';
import 'package:resqapp/components/evacuation_point_detail_modal.dart' as reusable;

class EvacuationPointDetailModal extends StatelessWidget {
  final EvacuationPoint evacuationPoint;

  const EvacuationPointDetailModal({
    Key? key,
    required this.evacuationPoint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return reusable.EvacuationPointDetailModal(
      evacuationPoint: evacuationPoint,
      onShowRoute: () {
        
      },
    );
  }
}

