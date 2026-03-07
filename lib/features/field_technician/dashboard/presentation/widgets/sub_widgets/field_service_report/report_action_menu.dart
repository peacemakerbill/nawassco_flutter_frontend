import 'package:flutter/material.dart';

import '../../../../../../public/auth/providers/auth_provider.dart';
import '../../../../models/field_service_report_model.dart';

class ReportActionMenu extends StatelessWidget {
  final FieldServiceReport report;
  final AuthState authState;
  final Function(String)? onActionSelected;

  const ReportActionMenu({
    super.key,
    required this.report,
    required this.authState,
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => _buildMenuItems(),
      onSelected: (value) {
        onActionSelected?.call(value);
      },
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    final items = <PopupMenuEntry<String>>[];

    items.add(
      const PopupMenuItem(
        value: 'view',
        child: ListTile(
          leading: Icon(Icons.visibility),
          title: Text('View Details'),
        ),
      ),
    );

    if (authState.hasAnyRole(['Admin', 'Manager'])) {
      items.add(
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit Report'),
          ),
        ),
      );
    }

    if (report.canSubmit &&
        (authState.user?['_id'] == report.technicianId ||
            authState.hasAnyRole(['Admin', 'Manager']))) {
      items.add(
        const PopupMenuItem(
          value: 'submit',
          child: ListTile(
            leading: Icon(Icons.send),
            title: Text('Submit for Approval'),
          ),
        ),
      );
    }

    if (report.canApprove &&
        authState.hasAnyRole(['Admin', 'Manager'])) {
      items.add(
        const PopupMenuItem(
          value: 'approve',
          child: ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Approve Report'),
          ),
        ),
      );
      items.add(
        const PopupMenuItem(
          value: 'reject',
          child: ListTile(
            leading: Icon(Icons.cancel),
            title: Text('Reject Report'),
          ),
        ),
      );
    }

    items.add(
      const PopupMenuItem(
        value: 'pdf',
        child: ListTile(
          leading: Icon(Icons.picture_as_pdf),
          title: Text('Generate PDF'),
        ),
      ),
    );

    if (authState.hasAnyRole(['Admin', 'Manager'])) {
      items.add(
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ),
      );
    }

    return items;
  }
}