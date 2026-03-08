import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppExpansionCard extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final List<Widget> children;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final List<Widget>? extraActions;
  final EdgeInsetsGeometry? childrenPadding;

  const AppExpansionCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.children,
    this.onEdit,
    this.onDelete,
    this.extraActions,
    this.childrenPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: title,
          subtitle: subtitle,
          leading: leading,
          childrenPadding: childrenPadding ?? const EdgeInsets.all(16),
          children: [
            ...children,
            const SizedBox(height: 16),
            Row(
              children: [
                if (extraActions != null) ...[
                  ...extraActions!,
                ],
                if (extraActions != null && (onEdit != null || onDelete != null))
                  const SizedBox(width: 12),
                if (onEdit != null)
                  IconButton.filledTonal(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: 12),
                if (onDelete != null)
                  IconButton.filledTonal(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    onPressed: onDelete,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withValues(alpha: 0.1),
                      foregroundColor: AppColors.error,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
