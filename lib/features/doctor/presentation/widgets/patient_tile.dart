import 'package:flutter/material.dart';

import '../../../auth/domain/entities/app_user.dart';

class PatientTile extends StatelessWidget {
  const PatientTile({
    required this.patient,
    required this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final AppUser patient;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            patient.displayName.isNotEmpty ? patient.displayName[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(patient.displayName, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
